import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/admin_bottom_nav.dart';

class AdminProfileScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  const AdminProfileScreen({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
  });

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Admin'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
              color: AppColors.primary,
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: const Icon(Icons.admin_panel_settings_rounded,
                            color: Colors.white, size: 46),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.name ?? 'Administrator',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'admin@helpdesk.unair.ac.id',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.accent.withOpacity(0.6)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield_rounded,
                            color: Colors.white, size: 14),
                        SizedBox(width: 6),
                        Text('Administrator',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats
                  Row(
                    children: [
                      _statChip('47', 'Total Tiket'),
                      const SizedBox(width: 12),
                      _statChip('12', 'Open'),
                      const SizedBox(width: 12),
                      _statChip('38', 'Total User'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _sectionHeader('Akun'),
                  _menuItem(context,
                      icon: Icons.person_outline_rounded,
                      label: 'Edit Profil',
                      onTap: () {}),
                  _menuItem(context,
                      icon: Icons.lock_outline_rounded,
                      label: 'Ganti Password',
                      onTap: () {}),

                  const SizedBox(height: 8),
                  _sectionHeader('Tampilan'),
                  _menuItem(context,
                      icon: themeMode == ThemeMode.dark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      label: themeMode == ThemeMode.dark
                          ? 'Mode Terang'
                          : 'Mode Gelap',
                      onTap: onToggleTheme,
                      trailing: Switch(
                        value: themeMode == ThemeMode.dark,
                        onChanged: (_) => onToggleTheme(),
                        activeThumbColor: AppColors.primary,
                      )),

                  const SizedBox(height: 8),
                  _sectionHeader('Sistem'),
                  _menuItem(context,
                      icon: Icons.bar_chart_rounded,
                      label: 'Laporan & Statistik',
                      onTap: () {}),
                  _menuItem(context,
                      icon: Icons.settings_rounded,
                      label: 'Pengaturan Sistem',
                      onTap: () {}),
                  _menuItem(context,
                      icon: Icons.info_outline_rounded,
                      label: 'Tentang Aplikasi',
                      onTap: () => _showAbout(context)),

                  const SizedBox(height: 8),
                  // Logout
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.logout_rounded,
                          color: Colors.red),
                      title: const Text('Keluar',
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600)),
                      onTap: () => _showLogout(context),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'E-Ticketing Helpdesk v1.0.0\n© 2026 Universitas Airlangga',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AdminBottomNav(
        currentIndex: 3,
        onTap: (i) {
          if (i == 0) {
            Navigator.pushReplacementNamed(context, '/admin-dashboard');
          }
          if (i == 1) {
            Navigator.pushReplacementNamed(context, '/admin-tickets');
          }
          if (i == 2) {
            Navigator.pushReplacementNamed(context, '/admin-users');
          }
        },
      ),
    );
  }

  Widget _statChip(String value, String label) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
              Text(label, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4, left: 4),
      child: Text(title.toUpperCase(),
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.textSecondaryLight)),
    );
  }

  Widget _menuItem(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap,
      Widget? trailing}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary, size: 22),
        title: Text(label, style: const TextStyle(fontSize: 14)),
        trailing: trailing ??
            const Icon(Icons.chevron_right_rounded, size: 20),
        onTap: onTap,
      ),
    );
  }

  void _showLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              AuthService().logout();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.headset_mic_rounded,
                color: AppColors.primary, size: 48),
            SizedBox(height: 12),
            Text('E-Ticketing Helpdesk',
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 16)),
            Text('Versi 1.0.0',
                style:
                    TextStyle(color: AppColors.textSecondaryLight)),
            SizedBox(height: 10),
            Text(
              'Panel Admin - DIV Teknik Informatika\nUniversitas Airlangga',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup')),
        ],
      ),
    );
  }
}