import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowPrimary,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.handyman, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                'LabourGo',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 32),
              Text('Welcome Back', style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 8),
              Text(
                'Log in to manage your bookings and find top-rated professionals.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSubtle),
              ),
              const SizedBox(height: 32),
              const CustomInput(
                label: 'Email Address',
                hint: 'Enter your email',
                prefixIcon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              const CustomInput(
                label: 'Password',
                hint: 'Enter your password',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot Password?',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.primaryBlue),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Login',
                onPressed: () {
                  // Handle login or navigation
                  Navigator.of(context).pushReplacementNamed('/service_browsing');
                },
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR', style: Theme.of(context).textTheme.labelSmall),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Continue with Google',
                isPrimary: false,
                icon: Icons.g_mobiledata,
                onPressed: () {},
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Continue with Apple',
                isPrimary: false,
                icon: Icons.apple,
                onPressed: () {},
              ),
              const SizedBox(height: 48),
              InkWell(
                onTap: () => Navigator.of(context).pushNamed('/sign_up'),
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSubtle),
                    children: [
                      const TextSpan(text: "Don't have an account? "),
                      TextSpan(
                        text: 'Sign Up',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.primaryBlue),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
