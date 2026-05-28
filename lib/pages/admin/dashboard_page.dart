// lib/pages/admin/admin_dashboard_page.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/ticket_store.dart';
import '../../widgets/admin_bottom_nav.dart';

class AdminDashboardScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  const AdminDashboardScreen({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
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

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final store = TicketStore();
    final pending = store.pendingTickets.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(widget.themeMode == ThemeMode.dark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded),
            onPressed: widget.onToggleTheme,
          ),
          Stack(
            children: [
              IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {}),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                      color: AppColors.accent, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin greeting
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF1A3557), Color(0xFF2B5089)]),
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
                    child: const Icon(Icons.admin_panel_settings_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, ${user?.name ?? 'Admin'} 👋',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('Administrator',
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

            const SizedBox(height: 24),

            Text('Statistik Sistem',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.15,
              children: [
                _buildStatCard(context, 'Total Tiket',
                    '${store.totalCount}',
                    Icons.confirmation_num_outlined, AppColors.primary),
                _buildStatCard(context, 'Menunggu',
                    '${store.openCount}',
                    Icons.hourglass_empty_rounded, AppColors.statusOpen),
                _buildStatCard(context, 'Diproses',
                    '${store.inProgressCount}',
                    Icons.autorenew_rounded, AppColors.statusInProgress),
                _buildStatCard(context, 'Selesai',
                    '${store.resolvedCount}',
                    Icons.check_circle_outline, AppColors.statusResolved),
              ],
            ),

            const SizedBox(height: 24),

            Text('Menu Admin',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.6,
              children: [
                _buildAdminMenu(context,
                    icon: Icons.list_alt_rounded,
                    label: 'Kelola Tiket',
                    subtitle: 'Lihat & proses tiket',
                    color: AppColors.primary,
                    onTap: () =>
                        Navigator.pushNamed(context, '/admin-tickets')),
                _buildAdminMenu(context,
                    icon: Icons.people_rounded,
                    label: 'Kelola User',
                    subtitle: 'Manajemen pengguna',
                    color: AppColors.statusResolved,
                    onTap: () =>
                        Navigator.pushNamed(context, '/admin-users')),
                _buildAdminMenu(context,
                    icon: Icons.bar_chart_rounded,
                    label: 'Laporan',
                    subtitle: 'Statistik tiket',
                    color: AppColors.statusInProgress,
                    onTap: () {}),
                _buildAdminMenu(context,
                    icon: Icons.settings_rounded,
                    label: 'Pengaturan',
                    subtitle: 'Konfigurasi sistem',
                    color: AppColors.statusClosed,
                    onTap: () {}),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tiket Perlu Tindakan',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/admin-tickets'),
                  child: const Text('Lihat Semua',
                      style: TextStyle(color: AppColors.accent)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (pending.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Tidak ada tiket pending',
                      style: TextStyle(color: Colors.grey.shade500)),
                ),
              )
            else
              ...pending.map((t) => _buildTicketItem(context, t)),
          ],
        ),
      ),
      bottomNavigationBar: AdminBottomNav(
        currentIndex: 0,
        onTap: (i) {
          if (i == 1)
            Navigator.pushNamed(context, '/admin-tickets');
          if (i == 2)
            Navigator.pushNamed(context, '/admin-users');
          if (i == 3)
            Navigator.pushNamed(context, '/admin-profile');
        },
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String count,
      IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 26),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(count,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: color)),
                Text(label, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminMenu(BuildContext context,
      {required IconData icon,
      required String label,
      required String subtitle,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 26),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
                Text(subtitle,
                    style: TextStyle(
                        color: color.withOpacity(0.7), fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketItem(
      BuildContext context, Map<String, dynamic> ticket) {
    final statusColor = _statusColor(ticket['status'] as String);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.confirmation_num_outlined,
              color: statusColor, size: 20),
        ),
        title: Text(ticket['title'] as String,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Oleh: ${ticket['user']}',
                style: const TextStyle(fontSize: 11)),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(ticket['status'] as String,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                Text(ticket['date'] as String,
                    style: const TextStyle(fontSize: 10)),
              ],
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => Navigator.pushNamed(
              context, '/admin-ticket-detail',
              arguments: ticket),
          style: ElevatedButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textStyle: const TextStyle(fontSize: 11),
          ),
          child: const Text('Proses'),
        ),
        onTap: () => Navigator.pushNamed(context, '/admin-ticket-detail',
            arguments: ticket),
      ),
    );
  }
}