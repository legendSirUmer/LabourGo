import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/section_title.dart';
import '../../widgets/stat_card_widget.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                  title: 'Completion Rate',
                  value: '87%',
                  icon: Icons.check_circle_outline,
                  color: AppTheme.successColor,
                  change: '↑ 3% vs last month',
                ),
                StatCardWidget(
                  title: 'Avg Rating',
                  value: '4.3★',
                  icon: Icons.star_outline,
                  color: AppTheme.warningColor,
                  change: '342 total reviews',
                ),
                StatCardWidget(
                  title: 'Total Bookings',
                  value: '750',
                  icon: Icons.book_online_outlined,
                  color: AppTheme.primaryColor,
                  change: '+68 this month',
                ),
                StatCardWidget(
                  title: 'Cancellation',
                  value: '13%',
                  icon: Icons.cancel_outlined,
                  color: AppTheme.dangerColor,
                  change: '↓ 2% improved',
                ),
              ],
            ),

            const SizedBox(height: 20),

            const SectionTitle('Bookings by Service'),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _progressRow(
                      'Plumbing',
                      0.72,
                      AppTheme.primaryColor,
                      '342 jobs',
                    ),
                    const SizedBox(height: 14),

                    _progressRow(
                      'Electrical',
                      0.42,
                      AppTheme.infoColor,
                      '198 jobs',
                    ),
                    const SizedBox(height: 14),

                    _progressRow(
                      'Painting',
                      0.25,
                      AppTheme.warningColor,
                      '121 jobs',
                    ),
                    const SizedBox(height: 14),

                    _progressRow(
                      'Carpentry',
                      0.18,
                      AppTheme.dangerColor,
                      '89 jobs',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            const SectionTitle('Top Providers'),

            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final data = [
                    {
                      'name': 'Ahmed Khan',
                      'jobs': '48',
                      'rating': '4.8',
                      'service': 'Plumbing',
                    },
                    {
                      'name': 'Muhammad Raza',
                      'jobs': '39',
                      'rating': '4.6',
                      'service': 'Electrical',
                    },
                    {
                      'name': 'Nadia Qureshi',
                      'jobs': '31',
                      'rating': '4.4',
                      'service': 'Painting',
                    },
                    {
                      'name': 'Hassan Baig',
                      'jobs': '24',
                      'rating': '4.2',
                      'service': 'Carpentry',
                    },
                  ];

                  final d = data[i];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withValues(
                        alpha: 0.1,
                      ),
                      child: Text(
                        d['name']![0],
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),

                    title: Text(
                      d['name']!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    subtitle: Text(
                      '${d['service']} · ${d['jobs']} jobs',
                      style: const TextStyle(fontSize: 11),
                    ),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          d['rating']!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            const SectionTitle('City Distribution'),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _progressRow(
                      'Karachi',
                      0.58,
                      AppTheme.primaryColor,
                      '58%',
                    ),
                    const SizedBox(height: 14),

                    _progressRow(
                      'Lahore',
                      0.27,
                      AppTheme.infoColor,
                      '27%',
                    ),
                    const SizedBox(height: 14),

                    _progressRow(
                      'Islamabad',
                      0.15,
                      AppTheme.successColor,
                      '15%',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressRow(
    String label,
    double val,
    Color color,
    String trailing,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              trailing,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
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
}