import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/cust_theme.dart';

class TwoFactorLoginScreen extends StatefulWidget {
  const TwoFactorLoginScreen({
    super.key,
    required this.challengeToken,
    required this.email,
  });

  final String challengeToken;
  final String email;

  @override
  State<TwoFactorLoginScreen> createState() => _TwoFactorLoginScreenState();
}

class _TwoFactorLoginScreenState extends State<TwoFactorLoginScreen> {
  final TextEditingController _codeCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    final code = _codeCtrl.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() => _error = 'Enter a valid 6-digit code.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await ApiService.verifyTwoFactorLogin(
        challengeToken: widget.challengeToken,
        otpCode: code,
      );
      if (!mounted) return;

      if (result.containsKey('tokens')) {
        Navigator.pop(context, result);
      } else {
        setState(() => _error = result['error'] ?? 'Invalid authentication code.');
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Unable to verify code. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Two-Factor Login'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.email,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter the 6-digit code from your Google Authenticator app.',
              style: TextStyle(fontSize: 16, color: AppColors.textDark),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _codeCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Authentication code',
                hintText: '000000',
                counterText: '',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(color: AppColors.error),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _verifyCode,
                child: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Verify & Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

