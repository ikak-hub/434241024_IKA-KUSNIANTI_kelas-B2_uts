// lib/services/ticket_store.dart
import 'package:flutter/foundation.dart';

class TicketStore extends ChangeNotifier {
  static final TicketStore _instance = TicketStore._internal();
  factory TicketStore() => _instance;
  TicketStore._internal();

  final List<Map<String, dynamic>> _tickets = [
    {
      'id': '#TKT-001',
      'title': 'Koneksi internet tidak stabil di lab A',
      'status': 'Open',
      'user': 'John Doe',
      'userId': '2',
      'date': '13 Apr 2026',
      'priority': 'High',
      'category': 'Jaringan / Internet',
      'description':
          'Koneksi internet di laboratorium A sering putus dan sangat mengganggu aktivitas perkuliahan.',
      'assignedTo': '-',
      'attachments': <String>[],
      'comments': <Map<String, dynamic>>[
        {
          'user': 'Helpdesk Tim',
          'role': 'Helpdesk',
          'message': 'Tiket Anda telah diterima. Kami akan segera menindaklanjuti.',
          'time': '13 Apr 2026 09:00',
          'isHelpdesk': true,
        },
      ],
    },
    {
      'id': '#TKT-002',
      'title': 'Printer tidak bisa digunakan di lantai 2',
      'status': 'In Progress',
      'user': 'John Doe',
      'userId': '2',
      'date': '12 Apr 2026',
      'priority': 'Medium',
      'category': 'Printer / Scanner',
      'description': 'Printer lantai 2 tidak terdeteksi oleh komputer.',
      'assignedTo': 'Teknisi A',
      'attachments': <String>[],
      'comments': <Map<String, dynamic>>[],
    },
    {
      'id': '#TKT-003',
      'title': 'Akses sistem akademik error',
      'status': 'Resolved',
      'user': 'Jane Smith',
      'userId': '3',
      'date': '10 Apr 2026',
      'priority': 'High',
      'category': 'Sistem / Software',
      'description': 'Tidak bisa login ke portal akademik.',
      'assignedTo': 'Teknisi B',
      'attachments': <String>[],
      'comments': <Map<String, dynamic>>[],
    },
    {
      'id': '#TKT-004',
      'title': 'Proyektor ruang rapat mati',
      'status': 'Open',
      'user': 'Jane Smith',
      'userId': '3',
      'date': '9 Apr 2026',
      'priority': 'Low',
      'category': 'Komputer / Hardware',
      'description': 'Proyektor di ruang rapat tidak menyala.',
      'assignedTo': '-',
      'attachments': <String>[],
      'comments': <Map<String, dynamic>>[],
    },
    {
      'id': '#TKT-005',
      'title': 'Koneksi VPN kampus tidak bisa connect',
      'status': 'Open',
      'user': 'Budi Santoso',
      'userId': '4',
      'date': '22 Mei 2026',
      'priority': 'High',
      'category': 'Jaringan / Internet',
      'description': 'VPN kampus tidak bisa diakses dari luar jaringan.',
      'assignedTo': '-',
      'attachments': <String>[],
      'comments': <Map<String, dynamic>>[],
    },
    {
      'id': '#TKT-006',
      'title': 'Software SPSS tidak bisa diinstall',
      'status': 'Open',
      'user': 'Siti Rahayu',
      'userId': '5',
      'date': '21 Mei 2026',
      'priority': 'Medium',
      'category': 'Sistem / Software',
      'description': 'Gagal install SPSS di laptop Windows 11.',
      'assignedTo': '-',
      'attachments': <String>[],
      'comments': <Map<String, dynamic>>[],
    },
    {
      'id': '#TKT-007',
      'title': 'Akun email mahasiswa baru belum aktif',
      'status': 'In Progress',
      'user': 'Ahmad Fauzi',
      'userId': '6',
      'date': '20 Mei 2026',
      'priority': 'High',
      'category': 'Email / Akun',
      'description': 'Email @student.unair.ac.id belum bisa digunakan.',
      'assignedTo': 'Teknisi C',
      'attachments': <String>[],
      'comments': <Map<String, dynamic>>[],
    },
    {
      'id': '#TKT-008',
      'title': 'Email kampus tidak bisa diakses',
      'status': 'Closed',
      'user': 'Dewi Lestari',
      'userId': '7',
      'date': '8 Apr 2026',
      'priority': 'High',
      'category': 'Email / Akun',
      'description': 'Tidak bisa masuk ke email @student.unair.ac.id',
      'assignedTo': 'Teknisi A',
      'attachments': <String>[],
      'comments': <Map<String, dynamic>>[],
    },
  ];

  int _ticketCounter = 9;

  // ── Getters ────────────────────────────────────────────────

  List<Map<String, dynamic>> get allTickets =>
      List.unmodifiable(_tickets.reversed.toList());

  List<Map<String, dynamic>> ticketsForUser(String userId) =>
      _tickets.reversed
          .where((t) => t['userId'] == userId)
          .toList();

  List<Map<String, dynamic>> get pendingTickets =>
      _tickets
          .where((t) => t['status'] == 'Open' || t['status'] == 'In Progress')
          .toList();

  int get totalCount => _tickets.length;
  int get openCount =>
      _tickets.where((t) => t['status'] == 'Open').length;
  int get inProgressCount =>
      _tickets.where((t) => t['status'] == 'In Progress').length;
  int get resolvedCount =>
      _tickets.where((t) => t['status'] == 'Resolved').length;

  int openCountForUser(String userId) =>
      _tickets.where((t) => t['userId'] == userId && t['status'] == 'Open').length;
  int resolvedCountForUser(String userId) =>
      _tickets.where((t) => t['userId'] == userId && t['status'] == 'Resolved').length;

  // ── Actions ────────────────────────────────────────────────

  /// Create a new ticket; returns the created ticket map
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
    final dateStr =
        '${now.day} ${_monthName(now.month)} ${now.year}';

    final ticket = <String, dynamic>{
      'id': id,
      'title': title,
      'status': 'Open',
      'user': userName,
      'userId': userId,
      'date': dateStr,
      'priority': priority,
      'category': category,
      'description': description,
      'assignedTo': '-',
      'attachments': List<String>.from(attachments),
      'comments': <Map<String, dynamic>>[
        {
          'user': 'Helpdesk Tim',
          'role': 'Helpdesk',
          'message':
              'Tiket Anda telah diterima. Kami akan segera menindaklanjuti.',
          'time': '$dateStr ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
          'isHelpdesk': true,
        },
      ],
    };

    _tickets.add(ticket);
    notifyListeners();
    return ticket;
  }

  /// Update status of a ticket by id
  void updateStatus(String ticketId, String newStatus) {
    final idx = _tickets.indexWhere((t) => t['id'] == ticketId);
    if (idx != -1) {
      _tickets[idx]['status'] = newStatus;
      notifyListeners();
    }
  }

  /// Add a comment to a ticket
  void addComment(String ticketId, Map<String, dynamic> comment) {
    final idx = _tickets.indexWhere((t) => t['id'] == ticketId);
    if (idx != -1) {
      (_tickets[idx]['comments'] as List).add(comment);
      notifyListeners();
    }
  }

  /// Assign technician
  void assignTechnician(String ticketId, String technician) {
    final idx = _tickets.indexWhere((t) => t['id'] == ticketId);
    if (idx != -1) {
      _tickets[idx]['assignedTo'] = technician;
      notifyListeners();
    }
  }

  String _monthName(int m) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[m];
  }
}