import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/ticket_store.dart';

class UserDashboardScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;
  const UserDashboardScreen(
      {super.key, required this.onToggleTheme, required this.themeMode});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
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
      case 'pending_approval':
        return AppColors.statusPending;
      case 'approved':
        return AppColors.statusOpen;
      case 'assigned_helpdesk':
        return AppColors.roleHelpdesk;
      case 'assigned_technical':
        return AppColors.accent;
      case 'in_progress':
        return AppColors.statusInProgress;
      case 'resolved':
        return AppColors.statusResolved;
      case 'rejected':
        return AppColors.statusRejected;
      default:
        return AppColors.statusClosed;
    }
  }

  String _flowLabel(String fs) {
    switch (fs) {
      case 'pending_approval':
        return 'Menunggu Approval';
      case 'approved':
        return 'Disetujui';
      case 'assigned_helpdesk':
        return 'Di Helpdesk';
      case 'assigned_technical':
        return 'Di Teknisi';
      case 'in_progress':
        return 'Sedang Dikerjakan';
      case 'resolved':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      default:
        return fs;
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = TicketStore();
    final user = AuthService().currentUser!;
    final myTickets = store.ticketsForUser(user.id);

    final pages = [
      _buildHome(myTickets, user),
      _buildTicketList(myTickets),
      _buildCreateTicket(user),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Ticketing Helpdesk'),
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
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Beranda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_num_outlined),
              activeIcon: Icon(Icons.confirmation_num_rounded),
              label: 'Tiket Saya'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline_rounded),
              activeIcon: Icon(Icons.add_circle_rounded),
              label: 'Buat Tiket'),
        ],
      ),
    );
  }

  Widget _buildHome(List<Map<String, dynamic>> myTickets, user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person,
                          color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Text('Halo, ${user.name} 👋',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                    'Layanan helpdesk siap membantu permasalahan IT Anda.',
                    style:
                        TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Alur
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.statusOpen.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.statusOpen.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Alur Layanan',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 8),
                _flowStep('1', 'Buat Tiket', 'Ajukan permasalahan Anda',
                    AppColors.primary),
                _flowStep('2', 'Approval Admin',
                    'Admin meninjau & menyetujui', AppColors.statusPending),
                _flowStep('3', 'Helpdesk',
                    'Helpdesk mengkaji & meneruskan', AppColors.roleHelpdesk),
                _flowStep('4', 'Technical Support',
                    'Teknisi menangani masalah', AppColors.roleTech),
                _flowStep('5', 'Selesai',
                    'Masalah terselesaikan', AppColors.statusResolved,
                    isLast: true),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stats
          Row(
            children: [
              _miniStat('Total', '${myTickets.length}', AppColors.primary),
              const SizedBox(width: 10),
              _miniStat(
                  'Proses',
                  '${myTickets.where((t) => t['flowStatus'] != 'resolved' && t['flowStatus'] != 'rejected').length}',
                  AppColors.statusInProgress),
              const SizedBox(width: 10),
              _miniStat(
                  'Selesai',
                  '${myTickets.where((t) => t['flowStatus'] == 'resolved').length}',
                  AppColors.statusResolved),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tiket Terbaru',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16)),
              TextButton(
                onPressed: () => setState(() => _currentIndex = 1),
                child: const Text('Lihat Semua',
                    style: TextStyle(color: AppColors.accent)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (myTickets.isEmpty)
            Center(
              child: Column(
                children: [
                  const Icon(Icons.inbox_outlined,
                      size: 48, color: AppColors.textSecondaryLight),
                  const SizedBox(height: 8),
                  const Text('Belum ada tiket'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => setState(() => _currentIndex = 2),
                    child: const Text('Buat Tiket Sekarang'),
                  ),
                ],
              ),
            )
          else
            ...myTickets.take(3).map((t) => _ticketItem(t)),
        ],
      ),
    );
  }

  Widget _flowStep(
      String num, String title, String desc, Color color,
      {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                  color: color, shape: BoxShape.circle),
              child: Center(
                child: Text(num,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            if (!isLast)
              Container(
                  width: 2, height: 24, color: color.withOpacity(0.3)),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: color)),
                Text(desc,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondaryLight)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTicketList(List<Map<String, dynamic>> myTickets) {
    if (myTickets.isEmpty) {
      return const Center(child: Text('Belum ada tiket'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myTickets.length,
      itemBuilder: (_, i) => _ticketItem(myTickets[i]),
    );
  }

  Widget _ticketItem(Map<String, dynamic> ticket) {
    final fs = ticket['flowStatus'] as String;
    final fc = _flowColor(fs);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(ticket['id'] as String,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                _badge(_flowLabel(fs), fc),
              ],
            ),
            const SizedBox(height: 6),
            Text(ticket['title'] as String,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text('${ticket['category']} · ${ticket['date']}',
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondaryLight)),
            if (ticket['assignedTechName'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                    'Ditangani: ${ticket['assignedTechName']}',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.roleTech,
                        fontWeight: FontWeight.w600)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateTicket(user) {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String category = 'Jaringan / Internet';
    String priority = 'Medium';
    bool isLoading = false;

    return StatefulBuilder(
      builder: (ctx, setS) => Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.statusOpen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.statusOpen.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: AppColors.statusOpen, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tiket Anda akan dikaji oleh admin terlebih dahulu sebelum ditangani.',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.statusOpen),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text('Judul Keluhan *',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                    hintText: 'Deskripsi singkat masalah Anda',
                    prefixIcon: Icon(Icons.title_rounded)),
                validator: (v) =>
                    v!.isEmpty ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              const Text('Kategori *',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category_outlined)),
                items: [
                  'Jaringan / Internet',
                  'Printer / Scanner',
                  'Komputer / Hardware',
                  'Sistem / Software',
                  'Email / Akun',
                  'Lainnya',
                ]
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setS(() => category = v!),
              ),
              const SizedBox(height: 16),

              const Text('Prioritas *',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final p in [
                    {'label': 'Low', 'color': Colors.green},
                    {'label': 'Medium', 'color': Colors.orange},
                    {'label': 'High', 'color': Colors.red},
                  ])
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setS(() => priority = p['label'] as String),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: priority == p['label']
                                ? (p['color'] as Color).withOpacity(0.15)
                                : null,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: priority == p['label']
                                  ? p['color'] as Color
                                  : Colors.grey.shade300,
                              width: priority == p['label'] ? 2 : 1,
                            ),
                          ),
                          child: Text(p['label'] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: p['color'] as Color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              const Text('Deskripsi Detail *',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: descCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                    hintText:
                        'Jelaskan masalah secara detail, kapan terjadi, dampaknya, dsb.'),
                validator: (v) =>
                    v!.isEmpty ? 'Deskripsi wajib diisi' : null,
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setS(() => isLoading = true);
                          await Future.delayed(
                              const Duration(milliseconds: 800));
                          TicketStore().createTicket(
                            userId: user.id,
                            userName: user.name,
                            title: titleCtrl.text.trim(),
                            category: category,
                            priority: priority,
                            description: descCtrl.text.trim(),
                          );
                          setS(() => isLoading = false);
                          if (ctx.mounted) {
                            showDialog(
                              context: ctx,
                              builder: (_) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(20)),
                                content: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_rounded,
                                        color: AppColors.statusResolved,
                                        size: 56),
                                    SizedBox(height: 12),
                                    Text('Tiket Berhasil Dibuat!',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700)),
                                    SizedBox(height: 8),
                                    Text(
                                        'Tiket Anda akan segera ditinjau oleh admin.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: AppColors
                                                .textSecondaryLight)),
                                  ],
                                ),
                                actions: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        setState(
                                            () => _currentIndex = 1);
                                      },
                                      child:
                                          const Text('Lihat Tiket Saya'),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, size: 18),
                            SizedBox(width: 8),
                            Text('Kirim Tiket'),
                          ],
                        ),
                ),
              ),
            ],
          ),
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
