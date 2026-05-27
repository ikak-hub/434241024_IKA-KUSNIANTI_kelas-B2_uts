import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  /// Returns null on success, error message on failure
  Future<String?> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 2)); // simulate network

    // Dummy credential check
    // Admin: admin / admin123
    // User: user / user123  (or any username with password "password")
    final Map<String, String> credentials = {
      'admin': 'admin123',
      'user': 'user123',
      'jane': 'password',
    };

    if (!credentials.containsKey(username)) {
      return 'Username tidak ditemukan';
    }
    if (credentials[username] != password) {
      return 'Password salah';
    }

    _currentUser = UserModel.dummyUsers.firstWhere(
      (u) => u.username == username,
    );
    return null; // success
  }

  void logout() {
    _currentUser = null;
  }

  Future<String?> register({
    required String name,
    required String email,
    required String username,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    // In real app, call API here
    return null; // success
  }
}