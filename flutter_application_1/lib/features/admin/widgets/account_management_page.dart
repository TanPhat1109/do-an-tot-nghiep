import 'package:flutter/material.dart';

import '../admin_account_service.dart';

class AccountManagementPage extends StatefulWidget {
  const AccountManagementPage({super.key});

  @override
  State<AccountManagementPage> createState() => _AccountManagementPageState();
}

class _AccountManagementPageState extends State<AccountManagementPage> {
  final AdminAccountService _service = AdminAccountService();
  final TextEditingController _searchController = TextEditingController();

  static const Color purple = Color(0xFF5945ED);

  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _roleFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    try {
      final users = await _service.getUsers();

      if (!mounted) return;

      setState(() {
        _users = users;
      });
    } catch (e) {
      if (mounted) {
        _showMessage('Lỗi tải tài khoản: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    return _users.where((user) {
      final name = user['full_name']?.toString().toLowerCase() ?? '';
      final email = user['email']?.toString().toLowerCase() ?? '';
      final role = user['role']?.toString() ?? '';

      final matchesSearch =
          name.contains(_searchQuery) || email.contains(_searchQuery);

      final matchesRole = _roleFilter == 'all' || role == _roleFilter;

      return matchesSearch && matchesRole;
    }).toList();
  }

  Future<void> _changeRole(Map<String, dynamic> user) async {
    final userId = user['id'] as int;
    final currentRole = user['role']?.toString() ?? 'user';
    final newRole = currentRole == 'admin' ? 'user' : 'admin';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận thay đổi quyền'),
        content: Text(
          'Bạn có chắc muốn đổi quyền tài khoản '
          '${user['full_name']} thành '
          '${newRole == 'admin' ? 'Admin' : 'User'} không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _service.updateUserRole(userId: userId, role: newRole);

      _showMessage('Đã cập nhật quyền tài khoản!');
      await _loadUsers();
    } catch (e) {
      _showMessage('Lỗi cập nhật quyền: $e', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDate(dynamic value) {
    if (value == null) return 'Không rõ';

    try {
      final date = DateTime.parse(value.toString()).toLocal();

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (_) {
      return 'Không rõ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final users = _filteredUsers;

    final adminCount = _users.where((user) => user['role'] == 'admin').length;

    final userCount = _users.length - adminCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quản lý tài khoản',
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Quản lý người dùng và phân quyền truy cập hệ thống.',
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),

        // Thống kê
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = [
              _statCard(
                'Tổng tài khoản',
                '${_users.length}',
                Icons.people_outline,
                purple,
              ),
              _statCard(
                'Người dùng',
                '$userCount',
                Icons.person_outline,
                Colors.blue,
              ),
              _statCard(
                'Quản trị viên',
                '$adminCount',
                Icons.admin_panel_settings_outlined,
                Colors.orange,
              ),
            ];

            if (constraints.maxWidth < 550) {
              return Column(
                children: cards.map((card) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: card,
                  );
                }).toList(),
              );
            }

            return Row(
              children: cards.map((card) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: card,
                  ),
                );
              }).toList(),
            );
          },
        ),

        const SizedBox(height: 28),

        // Tìm kiếm
        TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value.trim().toLowerCase();
            });
          },
          decoration: InputDecoration(
            hintText: 'Tìm theo tên hoặc email...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              tooltip: 'Xóa tìm kiếm',
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              icon: const Icon(Icons.close),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
          ),
        ),

        const SizedBox(height: 14),

        // Bộ lọc quyền
        Wrap(
          spacing: 8,
          children: [
            _filterChip('Tất cả', 'all'),
            _filterChip('User', 'user'),
            _filterChip('Admin', 'admin'),
          ],
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            const Expanded(
              child: Text(
                'Danh sách tài khoản',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              '${users.length} tài khoản',
              style: const TextStyle(
                color: purple,
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              tooltip: 'Tải lại',
              onPressed: _loadUsers,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: CircularProgressIndicator(),
            ),
          )
        else if (users.isEmpty)
          _emptyState(theme)
        else
          ...users.map((user) => _userCard(user, theme)),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final selected = _roleFilter == value;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: purple.withValues(alpha: 0.15),
      onSelected: (_) {
        setState(() => _roleFilter = value);
      },
    );
  }

  Widget _userCard(Map<String, dynamic> user, ThemeData theme) {
    final isAdmin = user['role'] == 'admin';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.25)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final info = Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: purple.withValues(alpha: 0.12),
                child: Text(
                  (user['full_name']?.toString().isNotEmpty == true)
                      ? user['full_name'].toString()[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['full_name']?.toString() ?? 'Không có tên',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user['email']?.toString() ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Ngày tạo: ${_formatDate(user['created_at'])}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final roleAction = Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: (isAdmin ? Colors.orange : Colors.blue).withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isAdmin ? 'ADMIN' : 'USER',
                  style: TextStyle(
                    color: isAdmin ? Colors.orange : Colors.blue,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => _changeRole(user),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Đổi quyền'),
              ),
            ],
          );

          if (constraints.maxWidth < 450) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                info,
                const SizedBox(height: 12),
                Align(alignment: Alignment.centerRight, child: roleAction),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: info),
              const SizedBox(width: 10),
              roleAction,
            ],
          );
        },
      ),
    );
  }

  Widget _emptyState(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: 45,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          const Text(
            'Không tìm thấy tài khoản',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          Text(
            'Thử thay đổi từ khóa hoặc bộ lọc.',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
