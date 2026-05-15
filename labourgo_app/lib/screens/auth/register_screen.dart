import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../widgets/error_banner.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;
  bool _hoverSignUp = false;
  bool _hoverLogin = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await ApiService.register(
        email: _emailCtrl.text.trim(),
        fullName: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );

      if (result.containsKey('tokens')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', result['tokens']['access']);
        await prefs.setString('refresh_token', result['tokens']['refresh']);
        await prefs.setString('user_name', _nameCtrl.text.trim());
        await prefs.setString('user_email', _emailCtrl.text.trim());
        await prefs.setString('user_phone', _phoneCtrl.text.trim());

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        // Show first error from response
        final errors = result as Map;
        final firstError = errors.values.first;
        setState(
          () => _error = firstError is List
              ? firstError.first.toString()
              : firstError.toString(),
        );
      }
    } catch (e) {
      setState(() => _error = 'Cannot connect to server.');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.9),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/labourGo.png',
                        width: 48,
                        height: 48,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'LabourGo',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Glass card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.6)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),
                        const Text(
                          'Join LabourGo today',
                          style: TextStyle(color: Colors.black54),
                        ),

                        const SizedBox(height: 24),

                        if (_error != null) ErrorBanner(message: _error!),

                        // Full Name
                        _buildLabel('Full Name'),
                        _buildField(
                          controller: _nameCtrl,
                          hint: 'Rabeen Asif',
                          icon: Icons.person_outlined,
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'Full name is required';
                            if (v.length < 3) {
                              return 'Name must be at least 3 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Email
                        _buildLabel('Email'),
                        _buildField(
                          controller: _emailCtrl,
                          hint: 'you@example.com',
                          icon: Icons.email_outlined,
                          keyboard: TextInputType.emailAddress,
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'Email is required';
                            if (!RegExp(
                              r'^[\w\.-]+@[\w\.-]+\.\w{2,}$',
                            ).hasMatch(v)) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Phone
                        _buildLabel('Phone'),
                        _buildField(
                          controller: _phoneCtrl,
                          hint: '03001234567',
                          icon: Icons.phone_outlined,
                          keyboard: TextInputType.phone,
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'Phone number is required';
                            final clean = v.replaceAll(RegExp(r'[^0-9]'), '');
                            if (!RegExp(r'^03[0-9]{9}$').hasMatch(clean)) {
                              return 'Enter a valid Pakistani number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password
                        _buildLabel('Password'),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _obscure,
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'Password is required';
                            if (v.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          style: const TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            hintStyle: TextStyle(color: Colors.black45),
                            prefixIcon: const Icon(
                              Icons.lock_outlined,
                              color: Colors.black54,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.black45,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: Colors.black.withOpacity(0.12),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: Colors.black.withOpacity(0.12),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        _hoverable(
                          onHover: (value) =>
                              setState(() => _hoverSignUp = value),
                          child: _primaryGradientButton(
                            text: 'Sign Up',
                            loading: _loading,
                            onPressed: _register,
                            isHovered: _hoverSignUp,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Center(
                          child: _authLink(
                            prefix: 'Already have an account? ',
                            action: 'Login',
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    ),
  );

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: controller,
    keyboardType: keyboard,
    validator: validator,
    style: const TextStyle(color: Colors.black87),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.black45),
      prefixIcon: Icon(icon, color: Colors.black54),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.black87),
      ),
      filled: true,
      fillColor: Colors.white,
    ),
  );

  Widget _authLink({
    required String prefix,
    required String action,
    required VoidCallback onPressed,
  }) {
    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.black54, fontSize: 13),
        children: [
          TextSpan(text: prefix),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: _hoverable(
              onHover: (value) => setState(() => _hoverLogin = value),
              child: GestureDetector(
                onTap: onPressed,
                child: Text(
                  action,
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                    decoration: _hoverLogin
                        ? TextDecoration.underline
                        : TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _primaryGradientButton({
    required String text,
    required bool loading,
    required VoidCallback onPressed,
    bool isHovered = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isHovered ? 0.2 : 0.12),
              blurRadius: isHovered ? 14 : 10,
              offset: Offset(0, isHovered ? 8 : 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                  ),
                )
              : Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _hoverable({
    required Widget child,
    required ValueChanged<bool> onHover,
  }) {
    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: child,
    );
  }
}
