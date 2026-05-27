import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final error = await AuthService().login(
      _usernameCtrl.text.trim(),
      _passwordCtrl.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      setState(() => _errorMessage = error);
      return;
    }

    // Route based on role
    final user = AuthService().currentUser!;
    if (user.isAdmin) {
      Navigator.pushReplacementNamed(context, '/admin-dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [AppColors.surfaceDark, AppColors.cardDark]
                        : [AppColors.primary, AppColors.primaryLight],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.headset_mic_rounded,
                          color: Colors.white, size: 30),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Selamat Datang',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Masuk ke akun E-Ticketing Helpdesk',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Form
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // Info hint box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.statusOpen.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.statusOpen.withOpacity(0.3)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Icon(Icons.info_outline,
                                  size: 14, color: AppColors.statusOpen),
                              SizedBox(width: 6),
                              Text('Demo Akun',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.statusOpen)),
                            ]),
                            SizedBox(height: 6),
                            Text('Admin  → username: admin  | pass: admin123',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.statusOpen)),
                            Text('User    → username: user   | pass: user123',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.statusOpen)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Error message
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red, size: 16),
                              const SizedBox(width: 8),
                              Text(_errorMessage!,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 13)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Username
                      _buildLabel('Username'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _usernameCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Masukkan username',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (v) =>
                            v!.isEmpty ? 'Username tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 20),

                      // Password
                      _buildLabel('Password'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Masukkan password',
                          prefixIcon:
                              const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) =>
                            v!.isEmpty ? 'Password tidak boleh kosong' : null,
                      ),

                      const SizedBox(height: 12),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Lupa Password?',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Masuk'),
                        ),
                      ),

                      const SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Belum punya akun?',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/register'),
                            child: const Text(
                              'Daftar Sekarang',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    );
  }
}