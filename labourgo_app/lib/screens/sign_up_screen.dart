import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _agreedToTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryBlue),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'LabourGo',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppTheme.primaryBlue),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text('Create Account', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 8),
            Text(
              'Join LabourGo to effortlessly find and manage high-quality labor services.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSubtle),
            ),
            const SizedBox(height: 32),
            const CustomInput(
              label: 'Full Name',
              hint: 'John Doe',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            const CustomInput(
              label: 'Email Address',
              hint: 'john@example.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.mail_outline,
            ),
            const SizedBox(height: 16),
            const CustomInput(
              label: 'Phone Number',
              hint: '+1 (555) 000-0000',
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
            ),
            const SizedBox(height: 16),
            const CustomInput(
              label: 'Password',
              hint: '••••••••',
              obscureText: true,
              prefixIcon: Icons.lock_outline,
              suffixIcon: Icon(Icons.visibility_off_outlined),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: _agreedToTerms,
                  activeColor: AppTheme.primaryBlue,
                  onChanged: (val) {
                    setState(() => _agreedToTerms = val ?? false);
                  },
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSubtle),
                      children: [
                        const TextSpan(text: 'I agree to the '),
                        TextSpan(
                          text: 'Terms and Conditions',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.primaryBlue),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.primaryBlue),
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Sign Up',
              onPressed: () {
                // Navigate or handle signup
              },
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Or sign up with', style: Theme.of(context).textTheme.labelSmall),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Continue with Google',
              isPrimary: false,
              icon: Icons.g_mobiledata, // Placeholder for Google icon
              onPressed: () {},
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Continue with Apple',
              isPrimary: false,
              icon: Icons.apple, // Placeholder for Apple icon
              onPressed: () {},
            ),
            const SizedBox(height: 32),
            Center(
              child: InkWell(
                onTap: () => Navigator.of(context).pushNamed('/login'),
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSubtle),
                    children: [
                      const TextSpan(text: 'Already have an account? '),
                      TextSpan(
                        text: 'Login',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.primaryBlue),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
