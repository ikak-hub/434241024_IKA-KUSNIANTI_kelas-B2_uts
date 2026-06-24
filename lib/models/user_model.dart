enum UserRole { admin, helpdesk, user }

UserRole userRoleFromString(String value) {
  switch (value) {
    case 'admin':
      return UserRole.admin;
    case 'helpdesk':
      return UserRole.helpdesk;
    default:
      return UserRole.user;
  }
}

String userRoleToString(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return 'admin';
    case UserRole.helpdesk:
      return 'helpdesk';
    case UserRole.user:
      return 'user';
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String username;
  final UserRole role;
  final bool isActive;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.role,
    this.isActive = true,
    this.avatarUrl,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isHelpdesk => role == UserRole.helpdesk;
  bool get isUser => role == UserRole.user;

  String get roleLabel {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.helpdesk:
        return 'Helpdesk';
      case UserRole.user:
        return 'User';
    }
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      username: map['username'] as String? ?? '',
      role: userRoleFromString(map['role'] as String? ?? 'user'),
      isActive: map['is_active'] as bool? ?? true,
      avatarUrl: map['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'role': userRoleToString(role),
      'is_active': isActive,
      'avatar_url': avatarUrl,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? username,
    UserRole? role,
    bool? isActive,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
