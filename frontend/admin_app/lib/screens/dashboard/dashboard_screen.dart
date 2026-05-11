import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/stat_card_widget.dart';
import '../providers/providers_list_screen.dart';
import '../users/users_screen.dart';
import '../reports/reports_screen.dart';
import '../finance/finance_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Pages shown in bottom nav
  final List<Widget> _pages = const [
    DashboardHome(),
    ProvidersListScreen(),
    UsersScreen(),
    ReportsScreen(),
    FinanceScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.handyman_outlined),
            selectedIcon: Icon(Icons.handyman),
            label: 'Providers',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: 'Users',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Finance',
          ),
        ],
      ),
    );
  }
}

// ─── Dashboard Home Content ────────────────────────────────
class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard', style: TextStyle(fontSize: 20)),
            Text(
              'Welcome back, ${user?.name ?? "Admin"}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white),
            ),
            onSelected: (value) {
              if (value == 'logout') {
                context.read<AuthProvider>().logout();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'profile', child: Text('Profile')),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Grid
            const Text(
              'Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: const [
                StatCardWidget(
                  title: 'Total Providers',
                  value: '142',
                  icon: Icons.handyman,
                  color: AppTheme.primaryColor,
                  change: '+12 this month',
                ),
                StatCardWidget(
                  title: 'Active Users',
                  value: '1,284',
                  icon: Icons.people,
                  color: AppTheme.successColor,
                  change: '+89 this month',
                ),
                StatCardWidget(
                  title: 'Pending Reviews',
                  value: '23',
                  icon: Icons.pending_actions,
                  color: AppTheme.warningColor,
                  change: 'Needs attention',
                ),
                StatCardWidget(
                  title: 'Total Revenue',
                  value: 'PKR 85K',
                  icon: Icons.attach_money,
                  color: AppTheme.accentColor,
                  change: '+18% vs last month',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Activity
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...List.generate(5, (i) => _buildActivityItem(i)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(int i) {
    final activities = [
      {
        'title': 'New provider registered',
        'subtitle': 'Ahmed Khan - Plumber',
        'icon': Icons.person_add,
      },
      {
        'title': 'Service completed',
        'subtitle': 'Job #1042 - Painting',
        'icon': Icons.check_circle,
      },
      {
        'title': 'Review submitted',
        'subtitle': '4.5 stars - Electrician',
        'icon': Icons.star,
      },
      {
        'title': 'Provider suspended',
        'subtitle': 'Inactive for 30 days',
        'icon': Icons.block,
      },
      {
        'title': 'Payment received',
        'subtitle': 'PKR 2,500 - Job #1038',
        'icon': Icons.payment,
      },
    ];

    final activity = activities[i];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          child: Icon(activity['icon'] as IconData,
              color: AppTheme.primaryColor, size: 20),
        ),
        title: Text(
          activity['title'] as String,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(activity['subtitle'] as String),
        trailing: Text(
          '${i + 1}h ago',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
      ),
    );
  }
}
