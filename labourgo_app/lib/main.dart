import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding/onboarding_splash.dart';
import 'screens/onboarding/onboarding_language.dart';
import 'screens/onboarding/onboarding_carousel.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/bookings/home_screen.dart';
import 'screens/customer_dashboard_temp.dart';
import 'screens/provider_screens/P_onboarding/provider_intro_screen.dart';
import 'screens/provider_screens/P_onboarding/provider_form_screen.dart';
import 'screens/provider_screens/P_onboarding/provider_signin_screen.dart';
import 'screens/provider_screens/provider_dashboard_screen.dart';
import 'screens/provider_screens/profile_screen.dart';
import 'screens/provider_screens/performance_screen.dart';
import 'screens/provider_screens/pricing_screen.dart';
import 'screens/provider_screens/availability_screen.dart';
import 'screens/provider_screens/certificate_screen.dart';


void main() {
  runApp(const LabourGoApp());
}

class LabourGoApp extends StatelessWidget {
  const LabourGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LabourGo',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const OnboardingSplash(), // ✅ keep this
      routes: {
        '/language': (context) => const OnboardingLanguage(),
        '/carousel': (context) => const OnboardingCarousel(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/customer_dashboard': (context) => const CustomerDashboardTemp(),
        '/provider_intro': (context) => const ProviderIntroScreen(),
        '/provider_form': (context) => const ProviderFormScreen(),
        '/provider_signin': (context) => const ProviderSignInScreen(),
        '/provider_dashboard': (context) => const ProviderDashboardScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/performance': (context) => const PerformanceScreen(),
        '/pricing': (context) => const PricingScreen(),
        '/availability': (context) => const AvailabilityScreen(),
        '/certificates': (context) => const CertificateScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
