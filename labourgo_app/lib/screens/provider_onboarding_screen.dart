import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';

class ProviderOnboardingScreen extends StatelessWidget {
  const ProviderOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'LabourGo',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppTheme.primaryBlue),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/login');
              },
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: AppTheme.borderSubtle),
                ),
              ),
              child: Text(
                'Log In',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.textSubtle),
              ),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text('Build your business,\non your terms.', style: Theme.of(context).textTheme.displayLarge),
                const SizedBox(height: 12),
                Text(
                  "Join LabourGo's network of elite professionals. Get connected with ready-to-hire clients and manage your schedule effortlessly.",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSubtle),
                ),
                const SizedBox(height: 24),
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDOMc_U10Y3clamQYlEl5SLCAR2dqlE0ko9En87YyqhZEYNiTUXuA0K7Lr3l64i9nShZj_fowY9GH_-3Gb62_cv3Qkb7hl0KUQPO4DigQZ0NGauKb6GISIcqcfz9wZg2NCwUbGWW8mUevNdXPNaZCRZztAQwmhuTUh1MYFkQrkoPTP0qdaswbOmZ2X524_Mma2KdoeoxEmgyXxVpsPQX85bWDEovuCF1CI4niBQnGBfqwwjrL9tWmE-noaPxCeTCRNiKrHcNXgdIlj4'
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: AppTheme.successGreen, size: 16),
                              const SizedBox(width: 4),
                              Text('4.9 Avg Rating', style: Theme.of(context).textTheme.labelSmall),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text('Why join as a Pro?', style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildBenefitCard(
                        context,
                        icon: Icons.schedule,
                        iconColor: AppTheme.deepMidnight,
                        iconBgColor: AppTheme.background,
                        title: 'Total Flexibility',
                        subtitle: 'Accept jobs only when you want to work.',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildBenefitCard(
                        context,
                        icon: Icons.payments,
                        iconColor: AppTheme.primaryBlue,
                        iconBgColor: AppTheme.primaryBlue.withOpacity(0.1),
                        title: 'Fast Payouts',
                        subtitle: 'Secure payments sent straight to your bank.',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.dashboard, color: Colors.white),
                            const SizedBox(height: 8),
                            Text('All-in-one Toolkit', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white)),
                            const SizedBox(height: 4),
                            Text(
                              'Manage bookings, chat with clients, and track earnings from one clean dashboard.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.8)),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Icon(Icons.phonelink_setup, size: 80, color: Colors.white.withOpacity(0.5)),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.verified_user, size: 32, color: AppTheme.borderSubtle.withOpacity(0.5)),
                      const SizedBox(height: 8),
                      Text(
                        'Over 10,000 professionals trust LabourGo to grow their independent businesses.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSubtle),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100), // Space for sticky CTA
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
              ),
              child: SafeArea(
                child: CustomButton(
                  text: 'Join as Pro',
                  icon: Icons.arrow_forward,
                  onPressed: () {
                    Navigator.of(context).pushNamed('/sign_up');
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13, color: AppTheme.textSubtle)),
        ],
      ),
    );
  }
}
