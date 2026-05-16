import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/section_title.dart';
import '../../widgets/stat_card_widget.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});
  @override
  State<FinanceScreen> createState() => _State();
}

class _State extends State<FinanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Tracking'),
        bottom: TabBar(
          controller: _tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Payments'),
            Tab(text: 'Bookings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [_buildOverview(), _buildPayments(), _buildBookings()],
      ),
    );
  }

  Widget _buildOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: const [
              StatCardWidget(
                title: 'Total Revenue',
                value: 'PKR 85K',
                icon: Icons.trending_up,
                color: AppTheme.successColor,
                change: 'This month',
              ),
              StatCardWidget(
                title: 'Commission',
                value: 'PKR 17K',
                icon: Icons.currency_rupee,
                color: AppTheme.primaryColor,
                change: '20% platform fee',
              ),
              StatCardWidget(
                title: 'Pending Payout',
                value: 'PKR 12K',
                icon: Icons.pending,
                color: AppTheme.warningColor,
                change: '8 providers',
              ),
              StatCardWidget(
                title: 'Refunds',
                value: 'PKR 3.2K',
                icon: Icons.replay,
                color: AppTheme.dangerColor,
                change: '4 this month',
              ),
            ],
          ),
          const SizedBox(height: 20),
          SectionTitle('Revenue by Service'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _progressRow(
                    'Plumbing',
                    0.60,
                    AppTheme.primaryColor,
                    'PKR 51K',
                  ),
                  const SizedBox(height: 14),
                  _progressRow(
                    'Electrical',
                    0.25,
                    AppTheme.infoColor,
                    'PKR 21K',
                  ),
                  const SizedBox(height: 14),
                  _progressRow(
                    'Painting',
                    0.15,
                    AppTheme.warningColor,
                    'PKR 13K',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SectionTitle('Monthly Trend'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    height: 120,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [55, 70, 45, 85, 65, 95, 75]
                          .map(
                            (h) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                child: Container(
                                  height: h.toDouble(),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(
                                      0.7,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['Dec', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun']
                        .map(
                          (m) => Text(
                            m,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressRow(String label, double val, Color color, String amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            Text(
              amount,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: val,
            minHeight: 8,
            backgroundColor: Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildPayments() {
    final payments = [
      {
        'id': 'TXN-1041',
        'user': 'Fatima Ahmed',
        'amount': 'PKR 3,500',
        'status': 'paid',
      },
      {
        'id': 'TXN-1040',
        'user': 'Ali Zaidi',
        'amount': 'PKR 2,000',
        'status': 'paid',
      },
      {
        'id': 'TXN-1039',
        'user': 'Sana Khan',
        'amount': 'PKR 5,000',
        'status': 'pending',
      },
      {
        'id': 'TXN-1038',
        'user': 'Tariq Hassan',
        'amount': 'PKR 1,200',
        'status': 'refunded',
      },
      {
        'id': 'TXN-1037',
        'user': 'Usman Malik',
        'amount': 'PKR 4,500',
        'status': 'paid',
      },
    ];
    final colors = {
      'paid': AppTheme.successColor,
      'pending': AppTheme.warningColor,
      'refunded': AppTheme.dangerColor,
    };

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: payments.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final p = payments[i];
              final c = colors[p['status']] ?? Colors.grey;
              return ListTile(
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: c.withOpacity(0.1),
                  child: Icon(Icons.receipt_long, color: c, size: 16),
                ),
                title: Text(
                  p['id']!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  p['user']!,
                  style: const TextStyle(fontSize: 11),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      p['amount']!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: c.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        p['status']!.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          color: c,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookings() {
    final bookings = [
      {
        'job': '#1042',
        'service': 'Plumbing',
        'provider': 'Ahmed Khan',
        'amount': 'PKR 3,500',
        'status': 'completed',
      },
      {
        'job': '#1041',
        'service': 'Electrical',
        'provider': 'Hassan Baig',
        'amount': 'PKR 2,200',
        'status': 'ongoing',
      },
      {
        'job': '#1040',
        'service': 'Painting',
        'provider': 'Nadia Qureshi',
        'amount': 'PKR 7,000',
        'status': 'scheduled',
      },
      {
        'job': '#1039',
        'service': 'Plumbing',
        'provider': 'Muhammad Raza',
        'amount': 'PKR 5,000',
        'status': 'completed',
      },
    ];
    final colors = {
      'completed': AppTheme.successColor,
      'ongoing': AppTheme.warningColor,
      'scheduled': AppTheme.infoColor,
    };

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bookings.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final b = bookings[i];
              final c = colors[b['status']] ?? Colors.grey;
              return ListTile(
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: c.withOpacity(0.1),
                  child: Icon(Icons.work_outline, color: c, size: 16),
                ),
                title: Text(
                  'Job ${b['job']} – ${b['service']}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  b['provider']!,
                  style: const TextStyle(fontSize: 11),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      b['amount']!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: c.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        b['status']!.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          color: c,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
