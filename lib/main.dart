import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'pages/splash_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/forgot_password_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/ticket_list_page.dart';
import 'pages/ticket_detail_page.dart';
import 'pages/ticket_tracking_page.dart';
import 'pages/notification_page.dart';
import 'pages/profile_page.dart';
import 'pages/setting_page.dart';
import 'pages/admin/dashboard_page.dart';
import 'pages/admin/ticket_management_page.dart';
import 'pages/admin/user_management_page.dart';
import 'pages/helpdesk/dashboard_page_hd.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jvuylecnnwpfdqnghpef.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp2dXlsZWNubndwZmRxbmdocGVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE5NzEyNzMsImV4cCI6MjA5NzU0NzI3M30._R1hC7_RBpo9sAr4tcK3MVqY4MDj4fq5_XSkrGAr3ZQ',
  );

  await NotificationService().initLocalNotifications();

  runApp(const HelpdeskApp());
}

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
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),

        // User
        '/dashboard': (context) => UserDashboardScreen(
              onToggleTheme: _toggleTheme,
              themeMode: _themeMode,
            ),
        '/tickets': (context) => const TicketListScreen(),
        '/ticket-detail': (context) => const TicketDetailScreen(),
        '/ticket-tracking': (context) => const TicketTrackingScreen(),
        '/notifications': (context) => const NotificationScreen(),
        '/profile': (context) => ProfileScreen(
              onToggleTheme: _toggleTheme,
              themeMode: _themeMode,
            ),
        '/settings': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return SettingScreen(
            onToggleTheme:
                (args?['onToggleTheme'] as VoidCallback?) ?? _toggleTheme,
            themeMode: (args?['themeMode'] as ThemeMode?) ?? _themeMode,
          );
        },

        // Admin
        '/admin-dashboard': (context) => AdminDashboardScreen(
              onToggleTheme: _toggleTheme,
              themeMode: _themeMode,
            ),
        '/admin-tickets': (context) => const AdminTicketManagementScreen(),
        '/admin-users': (context) => const AdminUserManagementScreen(),

        // Helpdesk
        '/helpdesk-dashboard': (context) => HelpdeskDashboardScreen(
              onToggleTheme: _toggleTheme,
              themeMode: _themeMode,
            ),
      },
    );
  }
}
