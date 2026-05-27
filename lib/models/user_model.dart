enum UserRole { admin, user }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String username;
  final UserRole role;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.role,
  });

  bool get isAdmin => role == UserRole.admin;

  String get roleLabel => role == UserRole.admin ? 'Admin' : 'User';

  static const List<UserModel> dummyUsers = [
    UserModel(
      id: '1',
      name: 'Administrator',
      email: 'admin@helpdesk.unair.ac.id',
      username: 'admin',
      role: UserRole.admin,
    ),
    UserModel(
      id: '2',
      name: 'John Doe',
      email: 'john.doe@student.unair.ac.id',
      username: 'user',
      role: UserRole.user,
    ),
    UserModel(
      id: '3',
      name: 'Jane Smith',
      email: 'jane.smith@student.unair.ac.id',
      username: 'jane',
      role: UserRole.user,
    ),
  ];
}