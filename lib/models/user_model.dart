enum UserRole { admin, helpdesk, technicalSupport, user }

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
  bool get isHelpdesk => role == UserRole.helpdesk;
  bool get isTechnicalSupport => role == UserRole.technicalSupport;
  bool get isUser => role == UserRole.user;



  String get roleLabel {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.helpdesk:
        return 'Helpdesk';
      case UserRole.technicalSupport:
        return 'Technical Support';
      case UserRole.user:
        return 'User';
    }
  }

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
      name: 'Wowo',
      email: 'wowo.doe@student.unair.ac.id',
      username: 'user',
      role: UserRole.user,
    ),
    UserModel(
      id: '3',
      name: 'Ika Helpdesk',
      email: 'Ika.helpdesk@unair.ac.id',
      username: 'helpdesk',
      role: UserRole.helpdesk,
    ),
    UserModel(
      id: '4',
      name: 'Tariq Teknisi',
      email: 'Tariq.teknisi@unair.ac.id',
      username: 'teknisi',
      role: UserRole.technicalSupport,
    ),
    UserModel(
      id: '5',
      name: 'Bahlil',
      email: 'Bahlil.smith@student.unair.ac.id',
      username: 'Buahlil',
      role: UserRole.user,
    ),
  ];
}