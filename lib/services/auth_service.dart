import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isHelpdesk => _currentUser?.isHelpdesk ?? false;
  bool get isTechnicalSupport => _currentUser?.isTechnicalSupport ?? false;
  bool get isUser => _currentUser?.isUser ?? false;

  /// Returns null on success, error message on failure
  Future<String?> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    // Credentials map
    final Map<String, String> credentials = {
      'admin': 'admin123',
      'user': 'user123',
      'helpdesk': 'helpdesk123',
      'teknisi': 'teknisi123',
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
    return null;
  }

  void logout() {
    _currentUser = null;
  }
}
