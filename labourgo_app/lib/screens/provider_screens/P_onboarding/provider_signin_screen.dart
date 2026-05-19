import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_service.dart';
import '../../../theme/app_theme.dart';

const _kBlue = AppColors.primary;
const _kBg = Color(0xFFF4F8FD);

class ProviderSignInScreen extends StatefulWidget {
  const ProviderSignInScreen({super.key});

  @override
  State<ProviderSignInScreen> createState() => _ProviderSignInScreenState();
}

class _ProviderSignInScreenState extends State<ProviderSignInScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (email.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and phone number')),
      );
      return;
    }

    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (!RegExp(r'^03[0-9]{9}$').hasMatch(cleanPhone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid Pakistani number')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final provider = await ApiService.findProviderByEmailPhone(
        email,
        cleanPhone,
      );

      if (!mounted) return;

      if (provider == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Provider not registered')),
        );
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final providerId = provider['provider_model_id'] ?? provider['id'];
      if (providerId is int) {
        await prefs.setInt('provider_id', providerId);
      } else if (providerId is String) {
        final parsed = int.tryParse(providerId);
        if (parsed != null) {
          await prefs.setInt('provider_id', parsed);
        }
      }
      await prefs.setString('user_email', email);
      await prefs.setString('user_phone', cleanPhone);
      await prefs.setString('user_name', (provider['name'] ?? '').toString());
      await prefs.setBool('is_logged_in', true);
      await prefs.setBool('is_provider_signed_in', true);

      Navigator.pushReplacementNamed(context, '/provider_dashboard');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _kBg,
              border: Border.all(color: Color(0xFFD0E4F5)),
            ),
            child: const Icon(
              Icons.chevron_left_rounded,
              color: _kBlue,
              size: 24,
            ),
          ),
        ),
        title: const Text(
          'Provider Sign In',
          style: TextStyle(color: _kBlue, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Email',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _kBlue,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'you@example.com',
                prefixIcon: Icon(Icons.email_outlined, color: _kBlue, size: 19),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(color: Color(0xFFD0E4F5), width: 1.2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(color: Color(0xFFD0E4F5), width: 1.2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Phone Number',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _kBlue,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: '03XX-XXXXXXX',
                prefixIcon: Icon(Icons.phone_outlined, color: _kBlue, size: 19),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(color: Color(0xFFD0E4F5), width: 1.2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(color: Color(0xFFD0E4F5), width: 1.2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          letterSpacing: 0.3,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
