import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/job_card.dart';

class ServiceBrowsingScreen extends StatelessWidget {
  const ServiceBrowsingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppTheme.primaryBlue),
          onPressed: () {},
        ),
        title: Text(
          'LabourGo',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppTheme.deepMidnight),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppTheme.primaryBlue),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.displayMedium,
                children: [
                  const TextSpan(text: 'Find professional help,\n'),
                  TextSpan(
                    text: 'instantly.',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppTheme.primaryBlue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text('What do you need done today?', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSubtle)),
            const SizedBox(height: 24),
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.search, color: AppTheme.textSubtle),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search for plumbers, cleaners...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSubtle),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Categories
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Categories', style: Theme.of(context).textTheme.displaySmall),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'SEE ALL',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.primaryBlue, letterSpacing: 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Category Grid
            Row(
              children: [
                Expanded(
                  child: _buildCategoryCard(
                    context,
                    icon: Icons.cleaning_services,
                    iconBgColor: AppTheme.primaryBlue.withOpacity(0.1),
                    iconColor: AppTheme.primaryBlue,
                    title: 'Cleaning',
                    subtitle: '120+ pros',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCategoryCard(
                    context,
                    icon: Icons.plumbing,
                    iconBgColor: const Color(0xFFC1EAF0),
                    iconColor: const Color(0xFF001F23),
                    title: 'Plumbing',
                    subtitle: '85+ pros',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF7DFBAF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.electric_bolt, color: Color(0xFF00210F)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Electrician', style: Theme.of(context).textTheme.labelLarge),
                        Text('Certified professionals', style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppTheme.textSubtle),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Featured Providers
            Text('Featured Providers', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 16),
            JobCard(
              title: 'Pristine Home Cleaners',
              subtitle: 'Deep Cleaning • Standard',
              price: '\$45/hr',
              imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDbWoZqaCqckWeDUu8PLVsiLiZHw-Qz-H-3jCuLu2aXu5Z3yyR37R10HNYsEbGdYLdoZuIkXM-gTzcIKPI8f-MprOma9B69r_zyPQrQcOYRAMAdH-cZlRHMu_onjQmhsG352fe8bzosd2CpW-kix7bMA53k_oDjCmkSel-adR0t5FLZaZ-d7lMsLoUzIMBUfxg0f7HhiPFbP0KwjORhICTkf7lao2aCWdf-xFQf7KzLjzLeQQR-UlntRnkI_QMKc-oBjk-fu1PbmWV0',
              onTap: () {
                Navigator.of(context).pushNamed('/provider_profile');
              },
            ),
            const SizedBox(height: 16),
            JobCard(
              title: 'Apex Plumbing Solutions',
              subtitle: 'Repairs • Installations',
              price: '\$65/hr',
              imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuD2qQpmSIhEXIDA6Er6gmFIxsNAqSLr66ylv9_lPedb1H8f9Liwf7HfIcDd4tLufNRRwjouvMKqHILZ5rfg16wDtzzQD6JOFQ8x0knJP7p-Ady5dkRDhfF_3GAh4F78ffiUlNI2MxdqjiqQcq47-oFOPjFLy86KVkA36JrTjbNQlDbx0_B7mf0vK5EzBSg_DysMoSoFcZ8hUDqCTh5eQyOdI2XHmmsWK62I88QmykjrBQAiyvfI6zYcC4pgdrbRPiAm4fPWq3LqR1n0',
              onTap: () {
                Navigator.of(context).pushNamed('/provider_profile');
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: AppTheme.textSubtle,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
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
          Text(subtitle, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
