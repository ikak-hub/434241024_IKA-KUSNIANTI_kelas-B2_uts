import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/admin/dashboard_page.dart';
import 'pages/helpdesk/dashboard_page_hd.dart';
import 'pages/techsupport/dashboard_page_tc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 1. Inisialisasi Supabase di sini sebelum aplikasi berjalan
void main() async {
  // Wajib ditambahkan agar proses async saat init Supabase berjalan lancar
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jvuylecnnwpfdqnghpef.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp2dXlsZWNubndwZmRxbmdocGVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE5NzEyNzMsImV4cCI6MjA5NzU0NzI3M30._R1hC7_RBpo9sAr4tcK3MVqY4MDj4fq5_XSkrGAr3ZQ', // <-- Taruh Anon Key panjangmu di sini
  );

  runApp(const HelpdeskApp());
}

// 2. Buat instance client global di bawah main untuk dipakai di page Login/Dashboard nanti
final supabase = Supabase.instance.client;

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