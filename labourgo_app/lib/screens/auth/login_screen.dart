import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../services/social_auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/error_banner.dart';
import '../customer_dashboard_temp.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading       = false;
  bool _obscure       = true;
  String? _error;
  bool _hoverSignIn = false;
  bool _hoverCreate = false;

  @override
  void initState() {
    super.initState();
    _prefillEmail();
    _redirectIfLoggedIn();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _prefillEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('user_email')?.trim();
    if (savedEmail != null && savedEmail.isNotEmpty) {
      _emailCtrl.text = savedEmail;
    }
  }

  Future<void> _redirectIfLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    if (!isLoggedIn) return;
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const CustomerDashboardTemp(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    });
  }

  Future<void> _onAuthSuccess(
    Map<String, dynamic> result, {
    String? email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', result['tokens']['access']);
    await prefs.setString('refresh_token', result['tokens']['refresh']);
    await prefs.setBool('is_logged_in', true);
    final user = result['user'];
    if (user is Map<String, dynamic>) {
      final userEmail = (user['email'] ?? '').toString();
      final userName = (user['full_name'] ?? '').toString();
      final userPhone = (user['phone'] ?? '').toString();
      if (userEmail.isNotEmpty) {
        await prefs.setString('user_email', userEmail);
      }
      if (userName.isNotEmpty) {
        await prefs.setString('user_name', userName);
      }
      if (userPhone.isNotEmpty) {
        await prefs.setString('user_phone', userPhone);
      }
    } else if (email != null && email.isNotEmpty) {
      await prefs.setString('user_email', email);
    }
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const CustomerDashboardTemp(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  Future<void> _socialLogin(Future<SocialAuthPayload> Function() signIn) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final payload = await signIn();
      final result = await ApiService.socialLogin(
        provider: payload.provider,
        idToken: payload.idToken,
        accessToken: payload.accessToken,
        email: payload.email,
        fullName: payload.fullName,
      );
      if (result.containsKey('tokens')) {
        await _onAuthSuccess(result, email: payload.email);
      } else {
        setState(() => _error = result['error'] ?? 'Login failed. Try again.');
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.toLowerCase().contains('cancelled')) {
        return;
      }
      setState(() => _error = msg.replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _login() async {
    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      setState(() => _error = 'Please enter your email and password.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final result = await ApiService.login(
        email:    _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );
      if (result.containsKey('tokens')) {
        await _onAuthSuccess(result, email: _emailCtrl.text.trim());
      } else {
        setState(() => _error = result['error'] ?? 'Login failed. Try again.');
      }
    } catch (e) {
      setState(() => _error = 'Cannot connect to server. Check your connection.');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
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
                    border: Border.all(
                      color: Colors.white.withOpacity(0.6),
                    ),
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
                        'Welcome Back',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),
                      const Text(
                        'Sign in to continue',
                        style: TextStyle(color: Colors.black54),
                      ),

                      const SizedBox(height: 24),

                      if (_error != null) ErrorBanner(message: _error!),

                      _label('Email', Colors.white),
                      _inputField(
                        _emailCtrl,
                        'you@example.com',
                        Icons.email_outlined,
                      ),

                      const SizedBox(height: 16),
                      _label('Password', Colors.white),
                      _passwordField(),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      _hoverable(
                        onHover: (value) =>
                            setState(() => _hoverSignIn = value),
                        child: _primaryGradientButton(
                          text: 'Sign In',
                          loading: _loading,
                          onPressed: _login,
                          isHovered: _hoverSignIn,
                        ),
                      ),

                      const SizedBox(height: 20),

                      _divider(),

                      const SizedBox(height: 20),
                      _socialButtons(),

                      const SizedBox(height: 20),
                      Center(
                        child: _authLink(
                          prefix: "Don't have an account? ",
                          action: 'Sign Up',
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          ),
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
    );
  }

  Widget _label(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.black87,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _inputField(
    TextEditingController controller,
    String hint,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.black45),
        prefixIcon: Icon(icon, color: Colors.black54, size: 20),
        filled: true,
        fillColor: Colors.white,
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
      ),
    );
  }

  Widget _passwordField() {
    return TextField(
      controller: _passwordCtrl,
      obscureText: _obscure,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        hintText: '••••••••',
        hintStyle: TextStyle(color: Colors.black45),
        prefixIcon:
            const Icon(Icons.lock_outline, color: Colors.black54, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            _obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.black45,
            size: 20,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
        filled: true,
        fillColor: Colors.white,
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
      ),
    );
  }

  Widget _divider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.black.withOpacity(0.2))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.black.withOpacity(0.2))),
      ],
    );
  }

  Widget _socialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialCircleButton(
          semanticLabel: 'Continue with Google',
          icon: const Icon(
            Icons.g_mobiledata,
            size: 28,
            color: Color(0xFFDB4437),
          ),
          onPressed: _loading
              ? null
              : () => _socialLogin(SocialAuthService.signInWithGoogle),
        ),
        const SizedBox(width: 16),
        _SocialCircleButton(
          semanticLabel: 'Continue with Apple',
          icon: const Icon(
            Icons.apple,
            size: 24,
            color: Colors.black,
          ),
          onPressed: _loading
              ? null
              : () => _socialLogin(SocialAuthService.signInWithApple),
        ),
        const SizedBox(width: 16),
        _SocialCircleButton(
          semanticLabel: 'Continue with Facebook',
          icon: const Icon(
            Icons.facebook,
            size: 22,
            color: Color(0xFF1877F2),
          ),
          onPressed: _loading
              ? null
              : () => _socialLogin(SocialAuthService.signInWithFacebook),
        ),
      ],
    );
  }

  Widget _authLink({
    required String prefix,
    required String action,
    required VoidCallback onPressed,
  }) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: Colors.black54,
          fontSize: 13,
        ),
        children: [
          TextSpan(text: prefix),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: _hoverable(
              onHover: (value) =>
                  setState(() => _hoverCreate = value),
              child: GestureDetector(
                onTap: onPressed,
                child: Text(
                  action,
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                    decoration: _hoverCreate
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

class _SocialCircleButton extends StatelessWidget {
  const _SocialCircleButton({
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: disabled ? AppColors.border.withOpacity(0.6) : AppColors.border,
                width: 1.2,
              ),
            ),
            alignment: Alignment.center,
            child: Opacity(opacity: disabled ? 0.5 : 1, child: icon),
          ),
        ),
      ),
    );
  }
}