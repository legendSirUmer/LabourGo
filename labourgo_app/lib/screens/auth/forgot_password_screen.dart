import 'package:flutter/material.dart';
import '../../theme/cust_theme.dart';
import 'email_phone_reset_screen.dart';
import 'google_authenticator_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String _selectedMethod = 'email';
  final TextEditingController _emailCtrl = TextEditingController();

  Future<bool?> _openEmailPhoneReset({String? initialEmail}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EmailPhoneResetScreen(initialEmail: initialEmail ?? ''),
      ),
    );
    if (result == true && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    _emailCtrl.text = widget.initialEmail;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: AppColors.border, width: 0.8),
            ),
            child: const Center(
              child: Icon(Icons.chevron_left_rounded, size: 24),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Title
            const Text(
              'Forgot Password',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            const Text(
              'Select which methods you\'d like to reset.',
              style: TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),

            const SizedBox(height: 32),

            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Account Email',
                hintText: 'you@example.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),

            const SizedBox(height: 20),

            // Email Option
            _resetMethodCard(
              selected: _selectedMethod == 'email',
              icon: Icons.email_outlined,
              iconBg: const Color(0xFFE3F2FD),
              iconColor: AppColors.primary,
              title: 'Email Address',
              subtitle: 'Verify with email and phone number.',
              onTap: () async {
                setState(() => _selectedMethod = 'email');
                await _openEmailPhoneReset();
              },
            ),

            const SizedBox(height: 16),

            // Google Authenticator Option
            _resetMethodCard(
              selected: _selectedMethod == 'google',
              icon: Icons.lock_outline,
              iconBg: const Color(0xFFFCE4EC),
              iconColor: AppColors.primary,
              title: 'Google Authenticator',
              subtitle: 'Send via authenticator securely.',
              onTap: () => setState(() => _selectedMethod = 'google'),
            ),

            const SizedBox(height: 48),

            // Reset Password Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  if (_selectedMethod == 'google') {
                    final email = _emailCtrl.text.trim();
                    if (email.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter your email address.'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }

                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GoogleAuthenticatorScreen(
                          email: email,
                          setupMode: false,
                          returnToCallerOnSuccess: true,
                        ),
                      ),
                    );

                    if (result == true && mounted) {
                      await _openEmailPhoneReset(initialEmail: email);
                    }
                  } else {
                    await _openEmailPhoneReset();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4682B4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _resetMethodCard({
    required bool selected,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool highlight = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Color(0xFF4682B4),
            width: highlight && selected ? 2 : 0.8,
          ),
          boxShadow: highlight && selected
              ? [
                  BoxShadow(
                    color: AppColors.success.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                  ),
                ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Icon(icon, color: iconColor, size: 28)),
            ),

            const SizedBox(width: 16),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            // Radio Button
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
