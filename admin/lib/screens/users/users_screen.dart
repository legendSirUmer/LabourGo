import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import 'user_detail_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});
  @override
  State<UsersScreen> createState() => _State();
}

class _State extends State<UsersScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchUsers();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final up = context.watch<UserProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<UserProvider>().fetchUsers(),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _search,
              decoration: const InputDecoration(
                hintText: 'Search users...',
                hintStyle: TextStyle(fontSize: 13),
                prefixIcon: Icon(Icons.search, size: 20),
                isDense: true,
              ),
              onChanged: (v) => context.read<UserProvider>().search(v),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                _miniStat('Total', up.totalCount, AppTheme.primaryColor),
                _miniStat('Active', up.activeCount, AppTheme.successColor),
                _miniStat('Inactive', up.inactiveCount, AppTheme.warningColor),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: _buildContent(up)),
        ],
      ),
    );
  }

  Widget _miniStat(String label, int count, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(UserProvider up) {
    if (up.status == LoadingStatus.loading)
      return const Center(child: CircularProgressIndicator());
    if (up.status == LoadingStatus.error)
      return Center(child: Text(up.errorMessage));
    if (up.users.isEmpty)
      return const EmptyState(
        message: 'No users found',
        icon: Icons.people_outline,
      );

    return RefreshIndicator(
      onRefresh: () => context.read<UserProvider>().fetchUsers(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: up.users.length,
        itemBuilder: (ctx, i) {
          final u = up.users[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              onTap: () => Navigator.push(
                ctx,
                MaterialPageRoute(builder: (_) => UserDetailScreen(user: u)),
              ),
              leading: CircleAvatar(
                backgroundColor: AppTheme.infoColor.withOpacity(0.1),
                child: Text(
                  u.fullName.isNotEmpty ? u.fullName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.infoColor,
                  ),
                ),
              ),
              title: Text(
                u.fullName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(u.email, style: const TextStyle(fontSize: 11)),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: u.isActive
                          ? AppTheme.successColor.withOpacity(0.1)
                          : AppTheme.dangerColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      u.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 10,
                        color: u.isActive
                            ? AppTheme.successColor
                            : AppTheme.dangerColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${u.bookingsCount ?? 0} bookings',
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
