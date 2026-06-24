import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

/// AuthService membungkus Supabase Auth + tabel `profiles`.
/// Mengimplementasikan FR-001 (Login), FR-002 (Logout), FR-003 (Register),
/// FR-004 (Reset Password), dan BR-001 (Authentication Service).
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool get isLoggedIn => _client.auth.currentSession != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isHelpdesk => _currentUser?.isHelpdesk ?? false;
  bool get isUser => _currentUser?.isUser ?? false;

  /// Dipanggil saat app start untuk memulihkan sesi yang sudah login.
  Future<UserModel?> restoreSession() async {
    final session = _client.auth.currentSession;
    if (session == null) return null;
    return await _loadProfile(session.user.id);
  }

  /// FR-001: Login menggunakan email/username + password.
  /// Mengembalikan null jika sukses, atau pesan error jika gagal.
  Future<String?> login(String usernameOrEmail, String password) async {
    try {
      String email = usernameOrEmail.trim();

      // Jika input bukan email (tidak ada '@'), cari email dari username
      if (!email.contains('@')) {
        final result = await _client
            .from('profiles')
            .select('email')
            .eq('username', email)
            .maybeSingle();
        if (result == null) {
          return 'Username tidak ditemukan';
        }
        email = result['email'] as String;
      }

      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user == null) {
        return 'Login gagal, silakan coba lagi';
      }

      final profile = await _loadProfile(res.user!.id);
      if (profile == null) {
        return 'Profil pengguna tidak ditemukan';
      }
      if (!profile.isActive) {
        await _client.auth.signOut();
        return 'Akun Anda telah dinonaktifkan. Hubungi admin.';
      }

      return null;
    } on AuthException catch (e) {
      return _mapAuthError(e.message);
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  /// FR-003: Register pengguna baru. Role selalu 'user' (lihat trigger
  /// handle_new_user di schema.sql) — Admin & Helpdesk dibuat manual oleh admin.
  Future<String?> register({
    required String name,
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final usernameTaken = await _client
          .from('profiles')
          .select('id')
          .eq('username', username)
          .maybeSingle();
      if (usernameTaken != null) {
        return 'Username sudah digunakan';
      }

      final res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'username': username},
      );

      if (res.user == null) {
        return 'Pendaftaran gagal, silakan coba lagi';
      }
      return null;
    } on AuthException catch (e) {
      return _mapAuthError(e.message);
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  /// FR-004: Reset Password — kirim email reset password via Supabase Auth.
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim());
      return null;
    } on AuthException catch (e) {
      return _mapAuthError(e.message);
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  /// Dipanggil dari halaman reset password (setelah klik link email) untuk
  /// menetapkan password baru pada sesi recovery yang aktif.
  Future<String?> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
      return null;
    } on AuthException catch (e) {
      return _mapAuthError(e.message);
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  /// FR-002: Logout.
  Future<void> logout() async {
    await _client.auth.signOut();
    _currentUser = null;
  }

  Future<void> updateProfile({
    String? name,
    String? avatarUrl,
  }) async {
    if (_currentUser == null) return;
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (updates.isEmpty) return;

    await _client.from('profiles').update(updates).eq('id', _currentUser!.id);
    _currentUser = _currentUser!.copyWith(name: name, avatarUrl: avatarUrl);
  }

  Future<UserModel?> _loadProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    _currentUser = UserModel.fromMap(data);
    return _currentUser;
  }

  String _mapAuthError(String message) {
    final m = message.toLowerCase();
    if (m.contains('invalid login credentials')) {
      return 'Email/username atau password salah';
    }
    if (m.contains('email not confirmed')) {
      return 'Email belum terverifikasi, cek inbox Anda';
    }
    if (m.contains('user already registered')) {
      return 'Email sudah terdaftar';
    }
    if (m.contains('password should be at least')) {
      return 'Password minimal 6 karakter';
    }
    return message;
  }
}
