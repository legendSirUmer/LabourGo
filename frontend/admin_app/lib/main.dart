import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/provider_provider.dart';
import 'app.dart';
import 'screens/admin/user_management_screen.dart';
import 'screens/admin/booking_management_screen.dart';
import 'screens/admin/payment_management_screen.dart';
import 'screens/admin/provider_management_screen.dart';
import 'screens/admin/review_management_screen.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  // Required before any async code in main()
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProviderProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/login_screen',
        routes: {
          '/login_screen': (context) => LoginScreen(),
          '/user-management': (context) => UserManagementScreen(),
          '/booking-management': (context) => BookingManagementScreen(),
          '/payment-management': (context) => PaymentManagementScreen(),
          '/provider-management': (context) => ProviderManagementScreen(),
          '/review-management': (context) => ReviewManagementScreen(),
        },
      ),
    ),
  );
}
