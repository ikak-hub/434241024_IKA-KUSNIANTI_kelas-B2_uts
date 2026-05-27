import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin_bottom_nav.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState
    extends State<AdminUserManagementScreen> {
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  final List<Map<String, dynamic>> _users = [
    {
      'id': '2',
      'name': 'John Doe',
      'email': 'john.doe@student.unair.ac.id',
      'username': 'user',
      'role': 'User',
      'status': 'Aktif',
      'tickets': 3,
    },
    {
      'id': '3',
      'name': 'Jane Smith',
      'email': 'jane.smith@student.unair.ac.id',
      'username': 'jane',
      'role': 'User',
      'status': 'Aktif',
      'tickets': 2,
    },
    {
      'id': '4',
      'name': 'Budi Santoso',
      'email': 'budi.santoso@student.unair.ac.id',
      'username': 'budi',
      'role': 'User',
      'status': 'Aktif',
      'tickets': 5,
    },
    {
      'id': '5',
      'name': 'Siti Rahayu',
      'email': 'siti.rahayu@student.unair.ac.id',
      'username': 'siti',
      'role': 'User',
      'status': 'Aktif',
      'tickets': 1,
    },
    {
      'id': '6',
      'name': 'Ahmad Fauzi',
      'email': 'ahmad.fauzi@student.unair.ac.id',
      'username': 'ahmad',
      'role': 'User',
      'status': 'Nonaktif',
      'tickets': 0,
    },
    {
      'id': '7',
      'name': 'Dewi Lestari',
      'email': 'dewi.lestari@student.unair.ac.id',
      'username': 'dewi',
      'role': 'User',
      'status': 'Aktif',
      'tickets': 4,
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_searchQuery.isEmpty) return _users;
    return _users
        .where((u) =>
            u['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
            u['email'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
            u['username'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _toggleStatus(Map<String, dynamic> user) {
    setState(() {
      user['status'] = user['status'] == 'Aktif' ? 'Nonaktif' : 'Aktif';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${user['name']} diubah ke ${user['status']}'),
        backgroundColor: user['status'] == 'Aktif'
            ? AppColors.statusResolved
            : Colors.red,
      ),
    );
  }

  void _showUserDetail(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                user['name'][0],
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 12),
            Text(user['name'],
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            Text(user['email'],
                style: const TextStyle(
                    color: AppColors.textSecondaryLight, fontSize: 13)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoChip('Username', '@${user['username']}',
                    AppColors.primary),
                _infoChip('Role', user['role'], AppColors.statusInProgress),
                _infoChip('Tiket', '${user['tickets']}',
                    AppColors.statusResolved),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _toggleStatus(user);
                    },
                    icon: Icon(
                      user['status'] == 'Aktif'
                          ? Icons.block
                          : Icons.check_circle_outline,
                      size: 16,
                    ),
                    label: Text(
                        user['status'] == 'Aktif' ? 'Nonaktifkan' : 'Aktifkan'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: user['status'] == 'Aktif'
                          ? Colors.red
                          : AppColors.statusResolved,
                      side: BorderSide(
                          color: user['status'] == 'Aktif'
                              ? Colors.red
                              : AppColors.statusResolved),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Tutup'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 16, color: color)),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondaryLight)),
      ],
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola User'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Summary chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                _summaryChip('Total', '${_users.length}', AppColors.primary),
                const SizedBox(width: 8),
                _summaryChip(
                    'Aktif',
                    '${_users.where((u) => u['status'] == 'Aktif').length}',
                    AppColors.statusResolved),
                const SizedBox(width: 8),
                _summaryChip(
                    'Nonaktif',
                    '${_users.where((u) => u['status'] == 'Nonaktif').length}',
                    Colors.red),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Cari nama, email, atau username...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Text('Tidak ada user ditemukan',
                        style: TextStyle(color: Colors.grey.shade500)))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final user = list[i];
                      final isActive = user['status'] == 'Aktif';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor:
                                AppColors.primary.withOpacity(0.1),
                            child: Text(
                              user['name'][0],
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary),
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(user['name'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (isActive
                                          ? AppColors.statusResolved
                                          : Colors.red)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  user['status'],
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isActive
                                          ? AppColors.statusResolved
                                          : Colors.red),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('@${user['username']} · ${user['email']}',
                                  style: const TextStyle(fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              Text('${user['tickets']} tiket diajukan',
                                  style: const TextStyle(fontSize: 11)),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.more_vert_rounded),
                            onPressed: () => _showUserDetail(user),
                          ),
                          onTap: () => _showUserDetail(user),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: AdminBottomNav(
        currentIndex: 2,
        onTap: (i) {
          if (i == 0)
            Navigator.pushReplacementNamed(context, '/admin-dashboard');
          if (i == 1)
            Navigator.pushReplacementNamed(context, '/admin-tickets');
          if (i == 3)
            Navigator.pushReplacementNamed(context, '/admin-profile');
        },
      ),
    );
  }

  Widget _summaryChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: color)),
            Text(label, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}