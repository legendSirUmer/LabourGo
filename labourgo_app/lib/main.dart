import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme/app_theme.dart';
import 'screens/onboarding/onboarding_splash.dart';
import 'screens/onboarding/onboarding_language.dart';
import 'screens/onboarding/onboarding_carousel.dart';
import 'screens/auth/login_screen.dart';
import 'screens/bookings/home_screen.dart';
import 'screens/provider_screens/P_onboarding/provider_intro_screen.dart';
import 'screens/provider_screens/P_onboarding/provider_form_screen.dart';
import 'screens/provider_screens/P_onboarding/provider_signin_screen.dart';
import 'screens/provider_screens/provider_dashboard_screen.dart';
import 'screens/provider_screens/profile_screen.dart';
import 'screens/provider_screens/availability_screen.dart';
import 'screens/provider_screens/pricing_screen.dart';
import 'screens/provider_screens/performance_screen.dart';
import 'screens/provider_screens/certificate_screen.dart';
import 'screens/provider_screens/booking_checking_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const LabourGoApp());
}

class LabourGoApp extends StatelessWidget {
  const LabourGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LabourGo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppRouter(),
      routes: {
        '/language': (context) => const OnboardingLanguage(),
        '/carousel': (context) => const OnboardingCarousel(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/provider_intro': (context) => const ProviderIntroScreen(),
        '/provider_form': (context) => const ProviderFormScreen(),
        '/provider_signin': (context) => const ProviderSignInScreen(),
        '/provider_dashboard': (context) => const ProviderDashboardScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/availability': (context) => const AvailabilityScreen(),
        '/pricing': (context) => const PricingScreen(),
        '/performance': (context) => const PerformanceScreen(),
        '/certificates': (context) => const CertificateScreen(),
        '/view-bookings': (context) => const BookingCheckingScreen(),
      },
    );
  }
}

/// 🔥 CENTRAL FLOW CONTROLLER
class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  @override
  void initState() {
    super.initState();
    _checkFlow();
  }

  Future<void> _checkFlow() async {
    final prefs = await SharedPreferences.getInstance();

    final seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
    final token = prefs.getString('access_token');

    await Future.delayed(const Duration(seconds: 2)); // splash delay

    if (!mounted) return;

    if (!seenOnboarding) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingSplash()),
      );
    } 
    else if (token != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } 
    else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}