import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/customer_onboarding_screen.dart';
import 'screens/provider_onboarding_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/login_screen.dart';
import 'screens/service_browsing_screen.dart';
import 'screens/provider_profile_screen.dart';
import 'screens/booking_confirmation_screen.dart';
import 'screens/payment_screen.dart';

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
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => const CustomerOnboardingScreen(),
        '/provider_onboarding': (context) => const ProviderOnboardingScreen(),
        '/sign_up': (context) => const SignUpScreen(),
        '/login': (context) => const LoginScreen(),
        '/service_browsing': (context) => const ServiceBrowsingScreen(),
        '/provider_profile': (context) => const ProviderProfileScreen(),
        '/booking_confirmation': (context) => const BookingConfirmationScreen(),
        '/payment': (context) => const PaymentScreen(),
      },
    );
  }
}
