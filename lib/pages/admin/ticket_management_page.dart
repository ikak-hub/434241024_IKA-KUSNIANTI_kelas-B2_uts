// lib/pages/admin/admin_ticket_management_page.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin_bottom_nav.dart';
import '../../services/ticket_store.dart';

class AdminTicketManagementScreen extends StatefulWidget {
  const AdminTicketManagementScreen({super.key});

  @override
  State<AdminTicketManagementScreen> createState() =>
      _AdminTicketManagementScreenState();
}

class _AdminTicketManagementScreenState
    extends State<AdminTicketManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    TicketStore().addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    TicketStore().removeListener(_refresh);
    super.dispose();
  }

  List<Map<String, dynamic>> _filtered(String status) {
    final all = TicketStore().allTickets;
    final list = status == 'All'
        ? all
        : all.where((t) => t['status'] == status).toList();
    if (_searchQuery.isEmpty) return list;
    return list
        .where((t) =>
            (t['title'] as String)
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (t['id'] as String)
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (t['user'] as String)
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'Open':
        return AppColors.statusOpen;
      case 'In Progress':
        return AppColors.statusInProgress;
      case 'Resolved':
        return AppColors.statusResolved;
      default:
        return AppColors.statusClosed;
    }
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  void _showStatusDialog(Map<String, dynamic> ticket) {
    String selectedStatus = ticket['status'] as String;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Update Status Tiket',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: StatefulBuilder(
          builder: (ctx, setS) => Column(
            mainAxisSize: MainAxisSize.min,
            children: ['Open', 'In Progress', 'Resolved', 'Closed']
                .map((s) => RadioListTile<String>(
                      title: Text(s,
                          style: TextStyle(
                              color: _statusColor(s),
                              fontWeight: FontWeight.w600)),
                      value: s,
                      groupValue: selectedStatus,
                      onChanged: (v) => setS(() => selectedStatus = v!),
                      activeColor: _statusColor(s),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              TicketStore()
                  .updateStatus(ticket['id'] as String, selectedStatus);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Status tiket ${ticket['id']} diubah ke $selectedStatus'),
                  backgroundColor: AppColors.statusResolved,
                ),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Tiket'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: AppColors.accent,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Open'),
            Tab(text: 'Progress'),
            Tab(text: 'Selesai'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Cari tiket atau nama user...',
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
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList('All'),
                _buildList('Open'),
                _buildList('In Progress'),
                _buildList('Resolved'),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AdminBottomNav(
        currentIndex: 1,
        onTap: (i) {
          if (i == 0) {
            Navigator.pushReplacementNamed(context, '/admin-dashboard');
          }
          if (i == 2) {
            Navigator.pushReplacementNamed(context, '/admin-users');
          }
          if (i == 3) {
            Navigator.pushReplacementNamed(context, '/admin-profile');
          }
        },
      ),
    );
  }

  Widget _buildList(String status) {
    final list = _filtered(status);
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('Tidak ada tiket',
                style: TextStyle(
                    color: Colors.grey.shade500, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final ticket = list[i];
        final statusColor = _statusColor(ticket['status'] as String);
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(ticket['id'] as String,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondaryLight)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color:
                            _priorityColor(ticket['priority'] as String)
                                .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(ticket['priority'] as String,
                          style: TextStyle(
                              color: _priorityColor(
                                  ticket['priority'] as String),
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(ticket['title'] as String,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.person_outline,
                        size: 13,
                        color: AppColors.textSecondaryLight),
                    const SizedBox(width: 4),
                    Text(ticket['user'] as String,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryLight)),
                    const SizedBox(width: 12),
                    const Icon(Icons.calendar_today_outlined,
                        size: 13,
                        color: AppColors.textSecondaryLight),
                    const SizedBox(width: 4),
                    Text(ticket['date'] as String,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryLight)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text(ticket['status'] as String,
                              style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () => _showStatusDialog(ticket),
                      icon: const Icon(Icons.edit_outlined, size: 14),
                      label: const Text('Update',
                          style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: AppColors.primary,
                        side:
                            const BorderSide(color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(
                          context, '/admin-ticket-detail',
                          arguments: ticket),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      child: const Text('Detail'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}