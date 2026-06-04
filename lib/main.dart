import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/admin/dashboard_page.dart';
import 'pages/helpdesk/dashboard_page_hd.dart';
import 'pages/techsupport/dashboard_page_tc.dart';

void main() {
  runApp(const HelpdeskApp());
}

class HelpdeskApp extends StatefulWidget {
  const HelpdeskApp({super.key});

  @override
  State<HelpdeskApp> createState() => _HelpdeskAppState();
}

class _HelpdeskAppState extends State<HelpdeskApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Ticketing Helpdesk',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),

        // User
        '/dashboard': (context) => UserDashboardScreen(
              onToggleTheme: _toggleTheme,
              themeMode: _themeMode,
            ),

        // Admin
        '/admin-dashboard': (context) => AdminDashboardScreen(
              onToggleTheme: _toggleTheme,
              themeMode: _themeMode,
            ),

        // Helpdesk
        '/helpdesk-dashboard': (context) => HelpdeskDashboardScreen(
              onToggleTheme: _toggleTheme,
              themeMode: _themeMode,
            ),

        // Technical Support
        '/tech-dashboard': (context) => TechSupportDashboardScreen(
              onToggleTheme: _toggleTheme,
              themeMode: _themeMode,
            ),
      },
    );
  }
}
