import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ticket_model.dart';

/// TicketService menggantikan TicketStore lama (in-memory) dengan integrasi
/// penuh ke Supabase Postgres + Realtime.
/// Mengimplementasikan BR-002 (Tiket Service) dan BR-005 (History Service).
class TicketService extends ChangeNotifier {
  static final TicketService _instance = TicketService._internal();
  factory TicketService() => _instance;
  TicketService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  List<TicketModel> _tickets = [];
  List<TicketModel> get tickets => List.unmodifiable(_tickets);

  StreamSubscription<List<Map<String, dynamic>>>? _ticketSub;
  bool _loading = false;
  bool get isLoading => _loading;

  static const String _ticketSelect =
      '*, profiles!tickets_user_id_fkey(name), helpdesk_profile:profiles!tickets_assigned_helpdesk_id_fkey(name)';

  // ── Load & Realtime ───────────────────────────────────────────────────

  /// Memuat semua tiket yang boleh dilihat user (dibatasi oleh RLS policy
  /// di Supabase: user lihat tiketnya sendiri, helpdesk lihat yang
  /// ditugaskan/belum ditugaskan, admin lihat semua).
  Future<void> loadTickets() async {
    _loading = true;
    notifyListeners();
    try {
      final data = await _client
          .from('tickets')
          .select(_ticketSelect)
          .order('created_at', ascending: false);
      _tickets = (data as List)
          .map((e) => TicketModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('loadTickets error: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Subscribe Realtime ke tabel tickets (BR-003: Supabase Realtime).
  /// Dipanggil sekali setelah login berhasil.
  void subscribeRealtime() {
    _ticketSub?.cancel();
    _ticketSub = _client
        .from('tickets')
        .stream(primaryKey: ['id'])
        .listen((_) {
      // Setiap ada perubahan di tabel tickets, reload (RLS tetap berlaku).
      loadTickets();
    });
  }

  void unsubscribeRealtime() {
    _ticketSub?.cancel();
    _ticketSub = null;
  }

  // ── Getters turunan (filter di sisi client dari _tickets yg sudah RLS-filtered) ──

  List<TicketModel> ticketsForUser(String userId) =>
      _tickets.where((t) => t.userId == userId).toList();

  List<TicketModel> ticketsForHelpdesk(String helpdeskId) => _tickets
      .where((t) =>
          t.assignedHelpdeskId == helpdeskId || t.status == TicketStatus.open)
      .toList();

  List<TicketModel> get pendingTickets => _tickets
      .where((t) =>
          t.status == TicketStatus.open || t.status == TicketStatus.assigned)
      .toList();

  int get totalCount => _tickets.length;
  int get openCount =>
      _tickets.where((t) => t.status == TicketStatus.open).length;
  int get inProgressCount =>
      _tickets.where((t) => t.status == TicketStatus.inProgress).length;
  int get resolvedCount =>
      _tickets.where((t) => t.status == TicketStatus.resolved).length;
  int get closedCount =>
      _tickets.where((t) => t.status == TicketStatus.closed).length;

  // ── Actions (FR-005, FR-006, FR-007) ──────────────────────────────────

  /// FR-005: User membuat tiket baru.
  Future<String?> createTicket({
    required String userId,
    required String title,
    required String category,
    required String priority,
    required String description,
    List<String> attachmentPaths = const [],
  }) async {
    try {
      final priorityValue = priority.toLowerCase();
      final inserted = await _client
          .from('tickets')
          .insert({
            'user_id': userId,
            'title': title,
            'category': category,
            'priority': priorityValue,
            'description': description,
            'status': 'open',
          })
          .select()
          .single();

      final ticketId = inserted['id'] as String;

      for (final path in attachmentPaths) {
        await _client.from('ticket_attachments').insert({
          'ticket_id': ticketId,
          'file_path': path,
          'file_name': path.split('/').last,
          'file_type': 'image',
          'uploaded_by': userId,
        });
      }

      await loadTickets();
      return null;
    } catch (e) {
      return 'Gagal membuat tiket: $e';
    }
  }

  /// FR-007: Admin/Helpdesk menugaskan tiket ke helpdesk tertentu.
  Future<String?> assignToHelpdesk(String ticketId, String helpdeskId) async {
    try {
      await _client.from('tickets').update({
        'assigned_helpdesk_id': helpdeskId,
        'status': 'assigned',
      }).eq('id', ticketId);
      await loadTickets();
      return null;
    } catch (e) {
      return 'Gagal menugaskan tiket: $e';
    }
  }

  /// FR-006: Helpdesk menerima tiket (assign ke diri sendiri).
  Future<String?> acceptTicket(String ticketId, String helpdeskId) async {
    return assignToHelpdesk(ticketId, helpdeskId);
  }

  /// FR-006/FR-007: Update status tiket (mulai dikerjakan, dsb).
  Future<String?> updateStatus(String ticketId, TicketStatus status) async {
    try {
      final updates = <String, dynamic>{
        'status': ticketStatusToString(status),
      };
      if (status == TicketStatus.resolved) {
        updates['resolved_at'] = DateTime.now().toIso8601String();
      }
      if (status == TicketStatus.closed) {
        updates['closed_at'] = DateTime.now().toIso8601String();
      }
      await _client.from('tickets').update(updates).eq('id', ticketId);
      await loadTickets();
      return null;
    } catch (e) {
      return 'Gagal mengubah status: $e';
    }
  }

  /// FR-006.6: Helpdesk menutup tiket yang sudah selesai ditangani.
  Future<String?> closeTicket(String ticketId) async {
    return updateStatus(ticketId, TicketStatus.closed);
  }

  /// BR-002.8: Admin menghapus tiket. Cascade ke history/comments/attachments
  /// sudah ditangani lewat `on delete cascade` di schema.sql.
  Future<String?> deleteTicket(String ticketId) async {
    try {
      await _client.from('tickets').delete().eq('id', ticketId);
      await loadTickets();
      return null;
    } catch (e) {
      return 'Gagal menghapus tiket: $e';
    }
  }

  /// FR-006: Helpdesk menyelesaikan tiket dengan catatan resolusi.
  Future<String?> resolveTicket(String ticketId, String resolutionNote) async {
    try {
      await _client.from('tickets').update({
        'status': 'resolved',
        'resolution_note': resolutionNote,
        'resolved_at': DateTime.now().toIso8601String(),
      }).eq('id', ticketId);
      await loadTickets();
      return null;
    } catch (e) {
      return 'Gagal menyelesaikan tiket: $e';
    }
  }

  // ── Komentar (FR-005.7) ───────────────────────────────────────────────

  Future<List<TicketCommentModel>> fetchComments(String ticketId) async {
    try {
      final data = await _client
          .from('ticket_comments')
          .select()
          .eq('ticket_id', ticketId)
          .order('created_at', ascending: true);
      return (data as List)
          .map((e) => TicketCommentModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('fetchComments error: $e');
      return [];
    }
  }

  Stream<List<TicketCommentModel>> commentsStream(String ticketId) {
    return _client
        .from('ticket_comments')
        .stream(primaryKey: ['id'])
        .eq('ticket_id', ticketId)
        .order('created_at')
        .map((rows) =>
            rows.map((e) => TicketCommentModel.fromMap(e)).toList());
  }

  Future<String?> addComment({
    required String ticketId,
    required String authorId,
    required String authorName,
    required String authorRole,
    required String message,
  }) async {
    try {
      await _client.from('ticket_comments').insert({
        'ticket_id': ticketId,
        'author_id': authorId,
        'author_name': authorName,
        'author_role': authorRole,
        'message': message,
      });
      return null;
    } catch (e) {
      return 'Gagal mengirim komentar: $e';
    }
  }

  // ── Riwayat & Tracking (FR-010, FR-011) ───────────────────────────────

  Future<List<TicketHistoryModel>> fetchHistory(String ticketId) async {
    try {
      final data = await _client
          .from('ticket_history')
          .select()
          .eq('ticket_id', ticketId)
          .order('created_at', ascending: true);
      return (data as List)
          .map((e) => TicketHistoryModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('fetchHistory error: $e');
      return [];
    }
  }

  // ── Attachments ───────────────────────────────────────────────────────

  Future<String> uploadAttachment(String ticketId, String localPath) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${localPath.split('/').last}';
    final storagePath = '$ticketId/$fileName';
    await _client.storage
        .from('ticket-attachments')
        .upload(storagePath, File(localPath));
    return storagePath;
  }

  Future<String> getAttachmentUrl(String storagePath) async {
    return _client.storage
        .from('ticket-attachments')
        .createSignedUrl(storagePath, 3600);
  }

  @override
  void dispose() {
    unsubscribeRealtime();
    super.dispose();
  }
}
