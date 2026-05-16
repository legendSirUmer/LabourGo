import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';

class CustomerOnboardingScreen extends StatelessWidget {
  const CustomerOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Image
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              width: double.infinity,
              child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCtw85gcvG1XAI4fKZeZI5nos8PH588l8VAqGIbajYxKpmYLzvxSt9dNiX61UGfCU2NIGehoclJfIX8a97d7takuJEJ2YXDlHqs-lIA8CwBKgZYWiEMyvAtZmP5R7otL3jNPR7dUwu9Cy4SBHwJFhCfS65HHqp5L72GUvxA0LA2UafLZ_Ha1tZFNfwHW05naRnKU13uL4HH35BU4ccw5SSJ9eRk_NR3YmJSGaxvvrG2POiQEuIJmQdWfoq6Q_G7wy31iyiTbIFnz6k_',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.white.withOpacity(0.9), Colors.white],
                        stops: const [0.5, 0.9, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 48,
                    left: 16,
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.handyman, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'LabourGo',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          
            // Content
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 32.0),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Effortless Utility.',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connect with reliable professionals for any task. Your marketplace for verified skills, on demand.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSubtle),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFeatureCard(
                          context,
                          icon: Icons.bolt,
                          iconColor: AppTheme.primaryBlue,
                          iconBgColor: AppTheme.primaryBlue.withOpacity(0.1),
                          title: 'Fast Matching',
                          subtitle: 'Hire in minutes',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFeatureCard(
                          context,
                          icon: Icons.verified_user,
                          iconColor: AppTheme.deepMidnight,
                          iconBgColor: AppTheme.background,
                          title: 'Verified Pros',
                          subtitle: 'Vetted & trusted',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Get Started',
                    icon: Icons.arrow_forward,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/sign_up');
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Log In',
                    isPrimary: false,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/login');
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
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
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
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
            child: Icon(icon, color: iconColor, size: 24),
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
