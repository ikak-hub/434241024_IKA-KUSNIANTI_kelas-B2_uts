import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AdminTicketDetailScreen extends StatefulWidget {
  const AdminTicketDetailScreen({super.key});

  @override
  State<AdminTicketDetailScreen> createState() =>
      _AdminTicketDetailScreenState();
}

class _AdminTicketDetailScreenState extends State<AdminTicketDetailScreen> {
  final _replyCtrl = TextEditingController();
  String? _currentStatus;
  String _assignedTo = 'Belum Ditugaskan';

  final List<Map<String, dynamic>> _comments = [
    {
      'user': 'User',
      'role': 'User',
      'message': 'Masalah sudah berlangsung sejak kemarin pagi.',
      'time': 'Kemarin 09:15',
      'isHelpdesk': false,
    },
  ];

  final List<String> _technicians = [
    'Belum Ditugaskan',
    'Teknisi A',
    'Teknisi B',
    'Teknisi C',
    'Teknisi D',
  ];

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  void _sendReply() {
    if (_replyCtrl.text.trim().isEmpty) return;
    setState(() {
      _comments.add({
        'user': 'Admin Helpdesk',
        'role': 'Admin',
        'message': _replyCtrl.text.trim(),
        'time': 'Baru saja',
        'isHelpdesk': true,
      });
    });
    _replyCtrl.clear();
  }

  void _updateStatus(Map<String, dynamic> ticket, String newStatus) {
    setState(() {
      ticket['status'] = newStatus;
      _currentStatus = newStatus;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status diubah ke $newStatus'),
        backgroundColor: AppColors.statusResolved,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ticket = (ModalRoute.of(context)?.settings.arguments as Map?) ??
        {
          'id': '#TKT-001',
          'title': 'Koneksi internet tidak stabil di lab A',
          'status': 'Open',
          'user': 'John Doe',
          'date': '13 Apr 2026',
          'priority': 'High',
          'description':
              'Koneksi internet di laboratorium A sering putus dan sangat mengganggu aktivitas perkuliahan.',
          'assignedTo': '-',
        };

    _currentStatus ??= ticket['status'] as String;

    final statusColor = _statusColor(_currentStatus!);

    return Scaffold(
      appBar: AppBar(
        title: Text(ticket['id'] ?? '#TKT'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) => _updateStatus(ticket, v),
            itemBuilder: (_) => [
              'Open',
              'In Progress',
              'Resolved',
              'Closed'
            ]
                .map((s) => PopupMenuItem(
                      value: s,
                      child: Text(s,
                          style: TextStyle(color: _statusColor(s))),
                    ))
                .toList(),
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ticket info card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ticket['title'] ?? '',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildBadge(_currentStatus!, statusColor),
                              _buildBadge(ticket['priority'] ?? 'High',
                                  _priorityColor(ticket['priority'] ?? 'High')),
                            ],
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(Icons.person_outline_rounded,
                              'Diajukan oleh', ticket['user'] ?? '-'),
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.calendar_today_outlined,
                              'Tanggal', ticket['date'] ?? '-'),
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.description_outlined,
                              'Deskripsi', ticket['description'] ?? '-'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Admin controls
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Kontrol Admin',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15)),
                          const SizedBox(height: 14),

                          // Status update
                          const Text('Update Status',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              'Open',
                              'In Progress',
                              'Resolved',
                              'Closed'
                            ]
                                .map((s) => GestureDetector(
                                      onTap: () =>
                                          _updateStatus(ticket, s),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: _currentStatus == s
                                              ? _statusColor(s)
                                              : _statusColor(s)
                                                  .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: _statusColor(s)),
                                        ),
                                        child: Text(s,
                                            style: TextStyle(
                                                color: _currentStatus == s
                                                    ? Colors.white
                                                    : _statusColor(s),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12)),
                                      ),
                                    ))
                                .toList(),
                          ),

                          const SizedBox(height: 14),
                          const Text('Tugaskan ke Teknisi',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _assignedTo,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(
                                  Icons.engineering_outlined,
                                  size: 20),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                            ),
                            items: _technicians
                                .map((t) => DropdownMenuItem(
                                    value: t, child: Text(t)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _assignedTo = v!),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Comments
                  const Text('Riwayat Komentar',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 12),
                  ..._comments.map((c) => _buildComment(c)),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // Reply box
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyCtrl,
                    decoration: const InputDecoration(
                        hintText: 'Tulis balasan admin...', isDense: true),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendReply,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondaryLight),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondaryLight)),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildComment(Map<String, dynamic> comment) {
    final isHelpdesk = comment['isHelpdesk'] as bool;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isHelpdesk
                ? AppColors.primary.withOpacity(0.15)
                : AppColors.accent.withOpacity(0.15),
            child: Icon(
              isHelpdesk ? Icons.admin_panel_settings : Icons.person,
              size: 18,
              color:
                  isHelpdesk ? AppColors.primary : AppColors.accent,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comment['user'],
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: isHelpdesk
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(comment['role'],
                          style: TextStyle(
                              fontSize: 10,
                              color: isHelpdesk
                                  ? AppColors.primary
                                  : AppColors.accent,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isHelpdesk
                        ? AppColors.primary.withOpacity(0.06)
                        : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(comment['message'],
                      style:
                          const TextStyle(fontSize: 13, height: 1.5)),
                ),
                const SizedBox(height: 4),
                Text(comment['time'],
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondaryLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'Open':
        return AppColors.statusOpen;
      case 'In Progress':
        return AppColors.statusInProgress;
      case 'Resolved':
        return AppColors.statusResolved;
      default:
        return AppColors.statusClosed;
    }
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}