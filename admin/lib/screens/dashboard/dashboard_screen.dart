import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/stat_card_widget.dart';
import '../../widgets/section_title.dart';

import '../providers/providers_list_screen.dart';
import '../users/users_screen.dart';
import '../finance/finance_screen.dart';
import '../reports/reports_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _idx = 0;

  final _pages = const [
    _DashboardHome(),
    ProvidersListScreen(),
    UsersScreen(),
    FinanceScreen(),
    ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_idx],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) {
          setState(() => _idx = i);
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
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Finance',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}

class _DashboardHome extends StatefulWidget {
  const _DashboardHome();

  @override
  State<_DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<_DashboardHome> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<DashboardProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/labourGo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.admin_panel_settings,
                    size: 20,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'Manrope',
                  ),
                ),
                Text(
                  'Welcome, ${auth.userName}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Manrope',
                  ),
                ),
              ],
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
              radius: 14,
              backgroundColor: Colors.white24,
              child: Icon(
                Icons.person,
                size: 16,
                color: Colors.white,
              ),
            ),
            onSelected: (v) {
              if (v == 'logout') {
                context.read<AuthProvider>().logout();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<DashboardProvider>().fetchStats();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle('Overview'),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.5,
                children: [
                  StatCardWidget(
                    title: 'Total Providers',
                    value: '${dash.totalProviders}',
                    icon: Icons.handyman,
                    color: AppTheme.primaryColor,
                    change: '${dash.pendingProviders} pending',
                  ),
                  StatCardWidget(
                    title: 'Active Users',
                    value: '${dash.activeUsers}',
                    icon: Icons.people,
                    color: AppTheme.successColor,
                    change: '${dash.totalUsers} total',
                  ),
                  StatCardWidget(
                    title: 'Total Bookings',
                    value: '${dash.totalBookings}',
                    icon: Icons.book_online,
                    color: AppTheme.warningColor,
                    change: '${dash.completedBookings} completed',
                  ),
                  StatCardWidget(
                    title: 'Revenue',
                    value: dash.revenueFormatted,
                    icon: Icons.currency_rupee,
                    color: AppTheme.dangerColor,
                    change: 'Total earned',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const SectionTitle('Recent Activity'),
              _buildActivityList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityList() {
    final activities = [
      {
        'title': 'New provider registered',
        'sub': 'Ahmed Khan – Plumber',
        'icon': Icons.person_add,
        'color': AppTheme.infoColor,
        'tag': 'New',
      },
      {
        'title': 'Service completed',
        'sub': 'Job #1042 – Painting',
        'icon': Icons.check_circle,
        'color': AppTheme.successColor,
        'tag': 'Done',
      },
      {
        'title': 'Review submitted',
        'sub': '4.5 stars – Electrician',
        'icon': Icons.star,
        'color': AppTheme.warningColor,
        'tag': 'Review',
      },
      {
        'title': 'Provider suspended',
        'sub': 'Inactive for 30 days',
        'icon': Icons.block,
        'color': AppTheme.dangerColor,
        'tag': 'Alert',
      },
      {
        'title': 'Payment received',
        'sub': 'PKR 2,500 – Job #1038',
        'icon': Icons.payment,
        'color': AppTheme.successColor,
        'tag': 'Paid',
      },
    ];

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final a = activities[i];

          return ListTile(
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: (a['color'] as Color).withValues(alpha: 0.1),
              child: Icon(
                a['icon'] as IconData,
                color: a['color'] as Color,
                size: 18,
              ),
            ),
            title: Text(
              a['title'] as String,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              a['sub'] as String,
              style: const TextStyle(fontSize: 11),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: (a['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                a['tag'] as String,
                style: TextStyle(
                  fontSize: 10,
                  color: a['color'] as Color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
