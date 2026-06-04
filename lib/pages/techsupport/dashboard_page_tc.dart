import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/ticket_store.dart';

class TechSupportDashboardScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;
  const TechSupportDashboardScreen(
      {super.key, required this.onToggleTheme, required this.themeMode});

  @override
  State<TechSupportDashboardScreen> createState() =>
      _TechSupportDashboardScreenState();
}

class _TechSupportDashboardScreenState
    extends State<TechSupportDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    TicketStore().addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    TicketStore().removeListener(_refresh);
    super.dispose();
  }

  Color _flowColor(String fs) {
    switch (fs) {
      case 'assigned_technical':
        return AppColors.accent;
      case 'in_progress':
        return AppColors.statusInProgress;
      case 'resolved':
        return AppColors.statusResolved;
      default:
        return AppColors.statusClosed;
    }
  }

  String _flowLabel(String fs) {
    switch (fs) {
      case 'assigned_technical':
        return 'Menunggu Tindakan';
      case 'in_progress':
        return 'Sedang Dikerjakan';
      case 'resolved':
        return 'Selesai';
      default:
        return fs;
    }
  }

  void _startHandling(Map<String, dynamic> ticket) {
    TicketStore().techStartHandling(
        ticket['id'], AuthService().currentUser?.name ?? 'Teknisi');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Mulai menangani tiket'),
          backgroundColor: AppColors.statusInProgress),
    );
  }

  void _resolveTicket(Map<String, dynamic> ticket) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Selesaikan Tiket',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tuliskan ringkasan penyelesaian:'),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(
                  hintText: 'Masalah telah diselesaikan dengan...'),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statusResolved),
            onPressed: () {
              Navigator.pop(context);
              TicketStore().techResolveTicket(
                ticket['id'],
                AuthService().currentUser?.name ?? 'Teknisi',
                ctrl.text.isNotEmpty
                    ? ctrl.text
                    : 'Masalah telah diselesaikan.',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Tiket berhasil diselesaikan!'),
                    backgroundColor: AppColors.statusResolved),
              );
            },
            child: const Text('Selesaikan'),
          ),
        ],
      ),
    );
  }

  void _addComment(Map<String, dynamic> ticket) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Update'),
        content: TextField(
          controller: ctrl,
          decoration:
              const InputDecoration(hintText: 'Update perbaikan...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                final now = DateTime.now();
                TicketStore().addComment(ticket['id'], {
                  'user':
                      AuthService().currentUser?.name ?? 'Teknisi',
                  'role': 'Technical Support',
                  'message': ctrl.text.trim(),
                  'time':
                      '${now.day}/${now.month}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                  'isHelpdesk': true,
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = TicketStore();
    final user = AuthService().currentUser!;
    final myTickets = store.ticketsForTechnicalSupport(user.id);

    final pages = [
      _buildDashboard(myTickets, user),
      _buildTicketList(myTickets),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Technical Support'),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.roleTech,
        actions: [
          IconButton(
            icon: Icon(widget.themeMode == ThemeMode.dark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded),
            onPressed: widget.onToggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              AuthService().logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: AppColors.roleTech,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.build_outlined),
              activeIcon: Icon(Icons.build_rounded),
              label: 'Tiket Saya'),
        ],
      ),
    );
  }

  Widget _buildDashboard(
      List<Map<String, dynamic>> myTickets, user) {
    final waiting = myTickets
        .where((t) => t['flowStatus'] == 'assigned_technical')
        .length;
    final inProgress =
        myTickets.where((t) => t['flowStatus'] == 'in_progress').length;
    final resolved =
        myTickets.where((t) => t['flowStatus'] == 'resolved').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppColors.roleTech,
                AppColors.roleTech.withOpacity(0.7)
              ]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.engineering_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Halo, ${user.name} 👋',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700)),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('Technical Support',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.roleTech.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppColors.roleTech.withOpacity(0.3)),
            ),
            child: const Text(
              'Tugas Technical Support:\n1. Terima tiket yang diteruskan helpdesk\n2. Tangani dan selesaikan masalah teknis\n3. Laporkan hasil perbaikan',
              style: TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              _miniStat('Menunggu', '$waiting', AppColors.accent),
              const SizedBox(width: 10),
              _miniStat(
                  'Dikerjakan', '$inProgress', AppColors.statusInProgress),
              const SizedBox(width: 10),
              _miniStat('Selesai', '$resolved', AppColors.statusResolved),
            ],
          ),
          const SizedBox(height: 20),

          const Text('Tiket Aktif',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),

          ...myTickets
              .where((t) =>
                  t['flowStatus'] == 'assigned_technical' ||
                  t['flowStatus'] == 'in_progress')
              .map((t) => _ticketCard(t)),

          if (myTickets
              .where((t) =>
                  t['flowStatus'] == 'assigned_technical' ||
                  t['flowStatus'] == 'in_progress')
              .isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Tidak ada tiket aktif',
                    style: TextStyle(
                        color: AppColors.textSecondaryLight)),
              ),
            ),

          if (resolved > 0) ...[
            const SizedBox(height: 10),
            const Text('Tiket Selesai',
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            ...myTickets
                .where((t) => t['flowStatus'] == 'resolved')
                .map((t) => _ticketCard(t)),
          ],
        ],
      ),
    );
  }

  Widget _buildTicketList(List<Map<String, dynamic>> myTickets) {
    if (myTickets.isEmpty) {
      return const Center(
          child: Text('Belum ada tiket yang ditugaskan'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myTickets.length,
      itemBuilder: (_, i) => _ticketCard(myTickets[i]),
    );
  }

  Widget _ticketCard(Map<String, dynamic> ticket) {
    final fs = ticket['flowStatus'] as String;
    final fc = _flowColor(fs);
    final canStart = fs == 'assigned_technical';
    final canResolve = fs == 'in_progress';
    final isResolved = fs == 'resolved';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(ticket['id'] as String,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                _badge(_flowLabel(fs), fc),
              ],
            ),
            const SizedBox(height: 6),
            Text(ticket['title'] as String,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(ticket['description'] as String,
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(
                'Oleh: ${ticket['user']} · ${ticket['priority']} · ${ticket['category']}',
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondaryLight)),
            if (ticket['assignedHelpdeskName'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                    'Diteruskan oleh: ${ticket['assignedHelpdeskName']}',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.roleHelpdesk,
                        fontWeight: FontWeight.w600)),
              ),
            if (!isResolved) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (canStart)
                    ElevatedButton.icon(
                      onPressed: () => _startHandling(ticket),
                      icon: const Icon(Icons.play_arrow_rounded, size: 14),
                      label: const Text('Mulai Tangani',
                          style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.roleTech,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  if (canResolve)
                    ElevatedButton.icon(
                      onPressed: () => _resolveTicket(ticket),
                      icon: const Icon(Icons.check_circle_outline,
                          size: 14),
                      label: const Text('Selesaikan',
                          style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.statusResolved,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  OutlinedButton.icon(
                    onPressed: () => _addComment(ticket),
                    icon: const Icon(Icons.update_rounded, size: 14),
                    label: const Text('Update',
                        style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: AppColors.roleTech,
                      side: BorderSide(color: AppColors.roleTech),
                    ),
                  ),
                ],
              ),
            ] else
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.statusResolved, size: 16),
                    const SizedBox(width: 6),
                    const Text('Tiket telah diselesaikan',
                        style: TextStyle(
                            color: AppColors.statusResolved,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(val,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: color)),
            Text(label, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600)),
    );
  }
}
