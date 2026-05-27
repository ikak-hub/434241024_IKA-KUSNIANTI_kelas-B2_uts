import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AdminBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AdminBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.textSecondaryLight,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt_outlined),
          activeIcon: Icon(Icons.list_alt_rounded),
          label: 'Tiket',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline_rounded),
          activeIcon: Icon(Icons.people_rounded),
          label: 'User',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Profil',
        ),
      ],
    );
  }
}