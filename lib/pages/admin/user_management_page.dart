import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin_bottom_nav.dart';
import '../../models/user_model.dart';

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
  List<UserModel> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .order('created_at', ascending: false);
      if (!mounted) return;
      setState(() {
        _users = (data as List).map((e) => UserModel.fromMap(e)).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data user: $e')),
      );
    }
  }

  List<UserModel> get _filtered {
    if (_searchQuery.isEmpty) return _users;
    final q = _searchQuery.toLowerCase();
    return _users
        .where((u) =>
            u.name.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q) ||
            u.username.toLowerCase().contains(q))
        .toList();
  }

  /// BR-002.9: Non-aktifkan / aktifkan pengguna — sekarang benar-benar
  /// persisten ke Supabase, bukan hanya setState lokal seperti versi lama.
  Future<void> _toggleStatus(UserModel user) async {
    final newStatus = !user.isActive;
    try {
      await Supabase.instance.client
          .from('profiles')
          .update({'is_active': newStatus})
          .eq('id', user.id);
      await _loadUsers();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${user.name} diubah ke ${newStatus ? "Aktif" : "Nonaktif"}'),
          backgroundColor:
              newStatus ? AppColors.statusResolved : Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengubah status: $e')),
      );
    }
  }

  Future<void> _changeRole(UserModel user, UserRole newRole) async {
    try {
      await Supabase.instance.client
          .from('profiles')
          .update({'role': userRoleToString(newRole)})
          .eq('id', user.id);
      await _loadUsers();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Role ${user.name} diubah menjadi ${userRoleToString(newRole)}'),
          backgroundColor: AppColors.statusResolved,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengubah role: $e')),
      );
    }
  }

  void _showUserDetail(UserModel user) {
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
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 12),
            Text(user.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(user.email,
                style: const TextStyle(
                    color: AppColors.textSecondaryLight, fontSize: 13)),
            const SizedBox(height: 16),

            const Text('Ubah Role',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: UserRole.values.map((r) {
                final selected = user.role == r;
                return ChoiceChip(
                  label: Text(userRoleToString(r)),
                  selected: selected,
                  onSelected: (_) {
                    Navigator.pop(context);
                    if (!selected) _changeRole(user, r);
                  },
                  selectedColor: AppColors.primary.withOpacity(0.2),
                );
              }).toList(),
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
                      user.isActive ? Icons.block : Icons.check_circle_outline,
                      size: 16,
                    ),
                    label: Text(user.isActive ? 'Nonaktifkan' : 'Aktifkan'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          user.isActive ? Colors.red : AppColors.statusResolved,
                      side: BorderSide(
                          color: user.isActive
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      _summaryChip(
                          'Total', '${_users.length}', AppColors.primary),
                      const SizedBox(width: 8),
                      _summaryChip(
                          'Aktif',
                          '${_users.where((u) => u.isActive).length}',
                          AppColors.statusResolved),
                      const SizedBox(width: 8),
                      _summaryChip(
                          'Nonaktif',
                          '${_users.where((u) => !u.isActive).length}',
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
                  child: RefreshIndicator(
                    onRefresh: _loadUsers,
                    child: list.isEmpty
                        ? Center(
                            child: Text('Tidak ada user ditemukan',
                                style: TextStyle(color: Colors.grey.shade500)))
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                            itemCount: list.length,
                            itemBuilder: (_, i) {
                              final user = list[i];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        AppColors.primary.withOpacity(0.1),
                                    child: Text(
                                      user.name.isNotEmpty
                                          ? user.name[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary),
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(user.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14),
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.roleHelpdesk
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(user.roleLabel,
                                            style: const TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.roleHelpdesk)),
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: (user.isActive
                                                  ? AppColors.statusResolved
                                                  : Colors.red)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          user.isActive ? 'Aktif' : 'Nonaktif',
                                          style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w600,
                                              color: user.isActive
                                                  ? AppColors.statusResolved
                                                  : Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                        '@${user.username} · ${user.email}',
                                        style: const TextStyle(fontSize: 11),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
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
                ),
              ],
            ),
      bottomNavigationBar: AdminBottomNav(
        currentIndex: 2,
        onTap: (i) {
          if (i == 0) Navigator.pushReplacementNamed(context, '/admin-dashboard');
          if (i == 1) Navigator.pushReplacementNamed(context, '/admin-tickets');
          if (i == 3) Navigator.pushNamed(context, '/notifications');
          if (i == 4) Navigator.pushNamed(context, '/profile');
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
                    fontWeight: FontWeight.w700, fontSize: 18, color: color)),
            Text(label, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
