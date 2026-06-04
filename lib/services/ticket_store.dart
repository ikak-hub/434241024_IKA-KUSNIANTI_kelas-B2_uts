import 'package:flutter/foundation.dart';

// Alur tiket:
// pending_approval → (admin approve) → approved → (helpdesk assign) → assigned_helpdesk
// → (helpdesk forward) → assigned_technical → (teknisi handle) → in_progress → resolved → closed

class TicketStore extends ChangeNotifier {
  static final TicketStore _instance = TicketStore._internal();
  factory TicketStore() => _instance;
  TicketStore._internal();

  final List<Map<String, dynamic>> _tickets = [
    {
      'id': '#TKT-001',
      'title': 'Koneksi internet tidak stabil di lab A',
      'status': 'Open',
      'flowStatus': 'approved',
      'user': 'John Doe',
      'userId': '2',
      'date': '13 Apr 2026',
      'priority': 'High',
      'category': 'Jaringan / Internet',
      'description':
          'Koneksi internet di laboratorium A sering putus dan sangat mengganggu aktivitas perkuliahan.',
      'assignedHelpdeskId': null,
      'assignedHelpdeskName': null,
      'assignedTechId': null,
      'assignedTechName': null,
      'approvedBy': 'Administrator',
      'attachments': <String>[],
      'comments': <Map<String, dynamic>>[
        {
          'user': 'Administrator',
          'role': 'Admin',
          'message': 'Tiket telah disetujui dan diteruskan ke helpdesk.',
          'time': '13 Apr 2026 09:05',
          'isHelpdesk': true,
        },
      ],
    },
    {
      'id': '#TKT-002',
      'title': 'Printer tidak bisa digunakan di lantai 2',
      'status': 'In Progress',
      'flowStatus': 'assigned_technical',
      'user': 'John Doe',
      'userId': '2',
      'date': '12 Apr 2026',
      'priority': 'Medium',
      'category': 'Printer / Scanner',
      'description': 'Printer lantai 2 tidak terdeteksi oleh komputer.',
      'assignedHelpdeskId': '3',
      'assignedHelpdeskName': 'Budi Helpdesk',
      'assignedTechId': '4',
      'assignedTechName': 'Siti Teknisi',
      'approvedBy': 'Administrator',
      'attachments': <String>[],
      'comments': <Map<String, dynamic>>[],
    },
    {
      'id': '#TKT-003',
      'title': 'Akses sistem akademik error',
      'status': 'Resolved',
      'flowStatus': 'resolved',
      'user': 'Jane Smith',
      'userId': '5',
      'date': '10 Apr 2026',
      'priority': 'High',
      'category': 'Sistem / Software',
      'description': 'Tidak bisa login ke portal akademik.',
      'assignedHelpdeskId': '3',
      'assignedHelpdeskName': 'Budi Helpdesk',
      'assignedTechId': '4',
      'assignedTechName': 'Siti Teknisi',
      'approvedBy': 'Administrator',
      'attachments': <String>[],
      'comments': <Map<String, dynamic>>[],
    },
    {
      'id': '#TKT-004',
      'title': 'Proyektor ruang rapat mati',
      'status': 'Open',
      'flowStatus': 'pending_approval',
      'user': 'Jane Smith',
      'userId': '5',
      'date': '9 Apr 2026',
      'priority': 'Low',
      'category': 'Komputer / Hardware',
      'description': 'Proyektor di ruang rapat tidak menyala.',
      'assignedHelpdeskId': null,
      'assignedHelpdeskName': null,
      'assignedTechId': null,
      'assignedTechName': null,
      'approvedBy': null,
      'attachments': <String>[],
      'comments': <Map<String, dynamic>>[],
    },
    {
      'id': '#TKT-005',
      'title': 'Koneksi VPN kampus tidak bisa connect',
      'status': 'Open',
      'flowStatus': 'pending_approval',
      'user': 'John Doe',
      'userId': '2',
      'date': '22 Mei 2026',
      'priority': 'High',
      'category': 'Jaringan / Internet',
      'description': 'VPN kampus tidak bisa diakses dari luar jaringan.',
      'assignedHelpdeskId': null,
      'assignedHelpdeskName': null,
      'assignedTechId': null,
      'assignedTechName': null,
      'approvedBy': null,
      'attachments': <String>[],
      'comments': <Map<String, dynamic>>[],
    },
    {
      'id': '#TKT-006',
      'title': 'Software SPSS tidak bisa diinstall',
      'status': 'Open',
      'flowStatus': 'assigned_helpdesk',
      'user': 'Jane Smith',
      'userId': '5',
      'date': '21 Mei 2026',
      'priority': 'Medium',
      'category': 'Sistem / Software',
      'description': 'Gagal install SPSS di laptop Windows 11.',
      'assignedHelpdeskId': '3',
      'assignedHelpdeskName': 'Budi Helpdesk',
      'assignedTechId': null,
      'assignedTechName': null,
      'approvedBy': 'Administrator',
      'attachments': <String>[],
      'comments': <Map<String, dynamic>>[],
    },
  ];

  int _ticketCounter = 7;

  // ── Getters ─────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> get allTickets =>
      List.unmodifiable(_tickets.reversed.toList());

  List<Map<String, dynamic>> ticketsForUser(String userId) =>
      _tickets.reversed.where((t) => t['userId'] == userId).toList();

  /// Tiket menunggu persetujuan admin
  List<Map<String, dynamic>> get pendingApprovalTickets =>
      _tickets.where((t) => t['flowStatus'] == 'pending_approval').toList();

  /// Alias for admin dashboard — tickets needing action (pending + approved)
  List<Map<String, dynamic>> get pendingTickets =>
      _tickets
          .where((t) =>
      t['flowStatus'] == 'pending_approval' ||
          t['flowStatus'] == 'approved')
          .toList();

  /// Tiket yang sudah diapprove admin (menunggu helpdesk)
  List<Map<String, dynamic>> get approvedTickets =>
      _tickets.where((t) => t['flowStatus'] == 'approved').toList();

  /// Tiket yang sudah di-assign ke helpdesk
  List<Map<String, dynamic>> ticketsForHelpdesk(String helpdeskId) =>
      _tickets
          .where((t) =>
              t['assignedHelpdeskId'] == helpdeskId ||
              t['flowStatus'] == 'approved')
          .toList()
          .reversed
          .toList();

  /// Tiket yang sudah di-assign ke technical support
  List<Map<String, dynamic>> ticketsForTechnicalSupport(String techId) =>
      _tickets
          .where((t) => t['assignedTechId'] == techId)
          .toList()
          .reversed
          .toList();

  int get totalCount => _tickets.length;
  int get openCount => _tickets.where((t) => t['status'] == 'Open').length;
  int get inProgressCount =>
      _tickets.where((t) => t['status'] == 'In Progress').length;
  int get resolvedCount =>
      _tickets.where((t) => t['status'] == 'Resolved').length;
  int get pendingCount => pendingApprovalTickets.length;

  // ── Actions ──────────────────────────────────────────────────────────────

  /// User membuat tiket baru (status: pending_approval)
  Map<String, dynamic> createTicket({
    required String userId,
    required String userName,
    required String title,
    required String category,
    required String priority,
    required String description,
    List<String> attachments = const [],
  }) {
    final id = '#TKT-${_ticketCounter.toString().padLeft(3, '0')}';
    _ticketCounter++;
    final now = DateTime.now();
    final dateStr = '${now.day} ${_monthName(now.month)} ${now.year}';

    final ticket = <String, dynamic>{
      'id': id,
      'title': title,
      'status': 'Open',
      'flowStatus': 'pending_approval',
      'user': userName,
      'userId': userId,
      'date': dateStr,
      'priority': priority,
      'category': category,
      'description': description,
      'assignedHelpdeskId': null,
      'assignedHelpdeskName': null,
      'assignedTechId': null,
      'assignedTechName': null,
      'approvedBy': null,
      'attachments': List<String>.from(attachments),
      'comments': <Map<String, dynamic>>[
        {
          'user': 'Sistem',
          'role': 'System',
          'message':
              'Tiket berhasil dibuat dan menunggu persetujuan admin.',
          'time':
              '$dateStr ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
          'isHelpdesk': false,
        },
      ],
    };

    _tickets.add(ticket);
    notifyListeners();
    return ticket;
  }

  /// Admin menyetujui tiket → flowStatus: approved
  void approveTicket(String ticketId, String adminName) {
    final idx = _tickets.indexWhere((t) => t['id'] == ticketId);
    if (idx != -1) {
      _tickets[idx]['flowStatus'] = 'approved';
      _tickets[idx]['approvedBy'] = adminName;
      _addSystemComment(idx, adminName, 'Admin',
          'Tiket telah disetujui. Diteruskan ke tim Helpdesk.');
      notifyListeners();
    }
  }

  /// Admin menolak tiket → flowStatus: rejected
  void rejectTicket(String ticketId, String adminName, String reason) {
    final idx = _tickets.indexWhere((t) => t['id'] == ticketId);
    if (idx != -1) {
      _tickets[idx]['flowStatus'] = 'rejected';
      _tickets[idx]['status'] = 'Closed';
      _addSystemComment(idx, adminName, 'Admin', 'Tiket ditolak. Alasan: $reason');
      notifyListeners();
    }
  }

  /// Helpdesk menerima & assign tiket ke diri sendiri → flowStatus: assigned_helpdesk
  void helpdeskAcceptTicket(
      String ticketId, String helpdeskId, String helpdeskName) {
    final idx = _tickets.indexWhere((t) => t['id'] == ticketId);
    if (idx != -1) {
      _tickets[idx]['flowStatus'] = 'assigned_helpdesk';
      _tickets[idx]['assignedHelpdeskId'] = helpdeskId;
      _tickets[idx]['assignedHelpdeskName'] = helpdeskName;
      _tickets[idx]['status'] = 'In Progress';
      _addSystemComment(idx, helpdeskName, 'Helpdesk',
          'Tiket diterima oleh helpdesk. Sedang dikaji sebelum diteruskan ke Technical Support.');
      notifyListeners();
    }
  }

  /// Helpdesk meneruskan ke Technical Support → flowStatus: assigned_technical
  void helpdeskForwardToTech(
      String ticketId, String techId, String techName, String helpdeskName) {
    final idx = _tickets.indexWhere((t) => t['id'] == ticketId);
    if (idx != -1) {
      _tickets[idx]['flowStatus'] = 'assigned_technical';
      _tickets[idx]['assignedTechId'] = techId;
      _tickets[idx]['assignedTechName'] = techName;
      _addSystemComment(idx, helpdeskName, 'Helpdesk',
          'Tiket diteruskan ke Technical Support: $techName.');
      notifyListeners();
    }
  }

  /// Technical Support mulai menangani → flowStatus: in_progress
  void techStartHandling(String ticketId, String techName) {
    final idx = _tickets.indexWhere((t) => t['id'] == ticketId);
    if (idx != -1) {
      _tickets[idx]['flowStatus'] = 'in_progress';
      _tickets[idx]['status'] = 'In Progress';
      _addSystemComment(idx, techName, 'Technical Support',
          'Technical Support mulai menangani masalah ini.');
      notifyListeners();
    }
  }

  /// Technical Support menyelesaikan tiket → flowStatus: resolved
  void techResolveTicket(String ticketId, String techName, String resolution) {
    final idx = _tickets.indexWhere((t) => t['id'] == ticketId);
    if (idx != -1) {
      _tickets[idx]['flowStatus'] = 'resolved';
      _tickets[idx]['status'] = 'Resolved';
      _addSystemComment(idx, techName, 'Technical Support',
          'Masalah telah diselesaikan. $resolution');
      notifyListeners();
    }
  }

  /// Update status manual
  void updateStatus(String ticketId, String newStatus) {
    final idx = _tickets.indexWhere((t) => t['id'] == ticketId);
    if (idx != -1) {
      _tickets[idx]['status'] = newStatus;
      notifyListeners();
    }
  }

  /// Tambah komentar
  void addComment(String ticketId, Map<String, dynamic> comment) {
    final idx = _tickets.indexWhere((t) => t['id'] == ticketId);
    if (idx != -1) {
      (_tickets[idx]['comments'] as List).add(comment);
      notifyListeners();
    }
  }

  void _addSystemComment(
      int idx, String user, String role, String message) {
    final now = DateTime.now();
    (_tickets[idx]['comments'] as List).add({
      'user': user,
      'role': role,
      'message': message,
      'time':
          '${now.day}/${now.month}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      'isHelpdesk': true,
    });
  }

  String _monthName(int m) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return months[m];
  }
}
