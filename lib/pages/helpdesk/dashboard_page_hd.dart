import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/ticket_store.dart';

class HelpdeskDashboardScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;
  const HelpdeskDashboardScreen(
      {super.key, required this.onToggleTheme, required this.themeMode});

  @override
  State<HelpdeskDashboardScreen> createState() =>
      _HelpdeskDashboardScreenState();
}

class _HelpdeskDashboardScreenState extends State<HelpdeskDashboardScreen> {
  int _currentIndex = 0;

  // Dummy list of technical support staff
  final List<Map<String, String>> _techStaff = [
    {'id': '4', 'name': 'Siti Teknisi'},
    {'id': '10', 'name': 'Ahmad Teknisi'},
    {'id': '11', 'name': 'Dewi Teknisi'},
  ];

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
      case 'approved':
        return AppColors.statusOpen;
      case 'assigned_helpdesk':
        return AppColors.statusInProgress;
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
      case 'approved':
        return 'Menunggu Helpdesk';
      case 'assigned_helpdesk':
        return 'Ditangani Helpdesk';
      case 'assigned_technical':
        return 'Diteruskan Teknisi';
      case 'in_progress':
        return 'Sedang Dikerjakan';
      case 'resolved':
        return 'Selesai';
      default:
        return fs;
    }
  }

  void _acceptTicket(Map<String, dynamic> ticket) {
    final user = AuthService().currentUser!;
    TicketStore().helpdeskAcceptTicket(ticket['id'], user.id, user.name);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Tiket diterima oleh helpdesk'),
          backgroundColor: AppColors.statusResolved),
    );
  }

  void _forwardToTech(Map<String, dynamic> ticket) {
    String? selectedTechId;
    String? selectedTechName;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text('Teruskan ke Technical Support',
              style: TextStyle(fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pilih teknisi yang akan menangani:',
                  style: TextStyle(fontSize: 13)),
              const SizedBox(height: 12),
              ..._techStaff.map((tech) => RadioListTile<String>(
                    title: Text(tech['name']!),
                    value: tech['id']!,
                    groupValue: selectedTechId,
                    onChanged: (v) {
                      setS(() {
                        selectedTechId = v;
                        selectedTechName = tech['name'];
                      });
                    },
                    activeColor: AppColors.primary,
                  )),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal')),
            ElevatedButton(
              onPressed: selectedTechId == null
                  ? null
                  : () {
                      Navigator.pop(ctx);
                      TicketStore().helpdeskForwardToTech(
                        ticket['id'],
                        selectedTechId!,
                        selectedTechName!,
                        AuthService().currentUser?.name ?? 'Helpdesk',
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Tiket diteruskan ke $selectedTechName'),
                            backgroundColor: AppColors.statusResolved),
                      );
                    },
              child: const Text('Teruskan'),
            ),
          ],
        ),
      ),
    );
  }

  void _addComment(Map<String, dynamic> ticket) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Komentar'),
        content: TextField(
          controller: ctrl,
          decoration:
              const InputDecoration(hintText: 'Tulis komentar...'),
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
                  'user': AuthService().currentUser?.name ?? 'Helpdesk',
                  'role': 'Helpdesk',
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
    final myTickets = store.ticketsForHelpdesk(user.id);

    final pages = [
      _buildDashboard(myTickets, user),
      _buildTicketList(myTickets),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Helpdesk Dashboard'),
        automaticallyImplyLeading: false,
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
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_outlined),
              activeIcon: Icon(Icons.list_alt_rounded),
              label: 'Tiket Saya'),
        ],
      ),
    );
  }

  Widget _buildDashboard(
      List<Map<String, dynamic>> myTickets, user) {
    final waiting =
        myTickets.where((t) => t['flowStatus'] == 'approved').length;
    final handling = myTickets
        .where((t) => t['flowStatus'] == 'assigned_helpdesk')
        .length;
    final forwarded = myTickets
        .where((t) =>
            t['flowStatus'] == 'assigned_technical' ||
            t['flowStatus'] == 'in_progress')
        .length;

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
              gradient: const LinearGradient(
                  colors: [Color(0xFF0891B2), Color(0xFF0E7490)]),
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
                  child: const Icon(Icons.support_agent_rounded,
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
                        child: const Text('Tim Helpdesk',
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

          // Alur tugas helpdesk
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.roleHelpdesk.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.roleHelpdesk.withOpacity(0.3)),
            ),
            child: const Text(
              'Tugas Helpdesk:\n1. Terima tiket yang disetujui admin\n2. Kaji dan teruskan ke Technical Support\n3. Monitor penanganan tiket',
              style: TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),

          // Stats
          Row(
            children: [
              _miniStat('Menunggu', '$waiting', AppColors.statusOpen),
              const SizedBox(width: 10),
              _miniStat('Ditangani', '$handling', AppColors.statusInProgress),
              const SizedBox(width: 10),
              _miniStat('Diteruskan', '$forwarded', AppColors.accent),
            ],
          ),
          const SizedBox(height: 20),

          // Tiket menunggu helpdesk
          const Text('Tiket Menunggu Tindakan',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),

          ...myTickets
              .where((t) =>
                  t['flowStatus'] == 'approved' ||
                  t['flowStatus'] == 'assigned_helpdesk')
              .map((t) => _ticketCard(t)),

          if (myTickets
              .where((t) =>
                  t['flowStatus'] == 'approved' ||
                  t['flowStatus'] == 'assigned_helpdesk')
              .isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Tidak ada tiket aktif',
                    style: TextStyle(
                        color: AppColors.textSecondaryLight)),
              ),
            ),
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
    final canAccept = fs == 'approved';
    final canForward = fs == 'assigned_helpdesk';

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
            Text('Oleh: ${ticket['user']} · ${ticket['date']}',
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondaryLight)),
            if (ticket['assignedTechName'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                    'Teknisi: ${ticket['assignedTechName']}',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.roleTech,
                        fontWeight: FontWeight.w600)),
              ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (canAccept)
                  ElevatedButton.icon(
                    onPressed: () => _acceptTicket(ticket),
                    icon: const Icon(Icons.inbox_rounded, size: 14),
                    label: const Text('Terima',
                        style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.roleHelpdesk,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                if (canForward)
                  ElevatedButton.icon(
                    onPressed: () => _forwardToTech(ticket),
                    icon: const Icon(Icons.forward_rounded, size: 14),
                    label: const Text('Teruskan ke Teknisi',
                        style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                OutlinedButton.icon(
                  onPressed: () => _addComment(ticket),
                  icon: const Icon(Icons.comment_outlined, size: 14),
                  label: const Text('Komentar',
                      style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: AppColors.primary,
                    side:
                        const BorderSide(color: AppColors.primary),
                  ),
                ),
              ],
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
            Text(label,
                style: const TextStyle(fontSize: 11)),
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
