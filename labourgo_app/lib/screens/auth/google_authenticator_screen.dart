import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import '../../services/api_service.dart';
import '../../theme/cust_theme.dart';

class GoogleAuthenticatorScreen extends StatefulWidget {
  const GoogleAuthenticatorScreen({
    super.key,
    this.email = '',
    this.setupMode = true,
    this.returnToCallerOnSuccess = false,
  });

  final String email;
  final bool setupMode;
  final bool returnToCallerOnSuccess;

  @override
  State<GoogleAuthenticatorScreen> createState() =>
      _GoogleAuthenticatorScreenState();
}

class _GoogleAuthenticatorScreenState extends State<GoogleAuthenticatorScreen> {
  final _codeCtrl = TextEditingController();
  bool _setupLoading = true;
  bool _verifying = false;
  String? _error;
  String _secret = '';
  String _otpauthUri = '';
  String get _email => widget.email.trim();

  @override
  void initState() {
    super.initState();
    if (widget.setupMode) {
      _loadTwoFactorSetup();
    } else {
      setState(() {
        _setupLoading = false;
      });
    }
  }

  Future<void> _loadTwoFactorSetup() async {
    if (_email.isEmpty) {
      setState(() {
        _setupLoading = false;
        _error = 'Please enter an email first.';
      });
      return;
    }

    setState(() {
      _setupLoading = true;
      _error = null;
    });

    try {
      final result = await ApiService.setupTwoFactor(email: _email);

      final secret = (result['secret'] ?? '').toString();
      final uri = (result['otpauth_uri'] ?? '').toString();

      // Check if backend returned valid data
      if (secret.isEmpty || uri.isEmpty) {
        setState(() {
          _setupLoading = false;
          _error = 'No account found for this email or 2FA is not enabled.';
        });
        return;
      }

      setState(() {
        _secret = secret;
        _otpauthUri = uri;
        _setupLoading = false;
      });
    } catch (_) {
      setState(() {
        _setupLoading = false;
        _error = 'Could not load authenticator setup for this email.';
      });
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    if (_email.isEmpty) {
      setState(() => _error = 'Email is required.');
      return;
    }
    if (widget.setupMode && (_secret.isEmpty || _otpauthUri.isEmpty)) {
      setState(() => _error = 'Authenticator setup is not ready yet.');
      return;
    }
    if (_codeCtrl.text.isEmpty) {
      setState(() => _error = 'Please enter the 6-digit code');
      return;
    }

    if (_codeCtrl.text.length != 6 ||
        !RegExp(r'^\d{6}$').hasMatch(_codeCtrl.text)) {
      setState(() => _error = 'Code must be exactly 6 digits');
      return;
    }

    setState(() {
      _verifying = true;
      _error = null;
    });

    try {
      final result = await ApiService.loginWithTwoFactor(
        email: _email,
        otpCode: _codeCtrl.text.trim(),
      );

      if (!mounted) return;
      if (!result.containsKey('tokens')) {
        setState(() {
          _verifying = false;
          _error = (result['error'] ?? 'Invalid authentication code.')
              .toString();
        });
        return;
      }

      if (widget.returnToCallerOnSuccess) {
        if (!mounted) return;
        setState(() => _verifying = false);
        Navigator.pop(context, true);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', result['tokens']['access']);
      await prefs.setString('refresh_token', result['tokens']['refresh']);
      await prefs.setBool('is_logged_in', true);

      final user = result['user'];
      final role = (user is Map ? (user['role'] ?? '').toString() : '')
          .toLowerCase();
      final userEmail = (user is Map
          ? (user['email'] ?? '').toString()
          : _email);
      final userName = (user is Map
          ? (user['full_name'] ?? '').toString()
          : '');
      final userPhone = (user is Map ? (user['phone'] ?? '').toString() : '');
      if (userEmail.isNotEmpty) await prefs.setString('user_email', userEmail);
      if (userName.isNotEmpty) await prefs.setString('user_name', userName);
      if (userPhone.isNotEmpty) await prefs.setString('user_phone', userPhone);
      final isProvider = role == 'provider';
      await prefs.setBool('is_provider_signed_in', isProvider);

      if (!mounted) return;
      setState(() => _verifying = false);
      Navigator.pushNamedAndRemoveUntil(
        context,
        isProvider ? '/provider_dashboard' : '/home',
        (_) => false,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _error = 'Unable to verify code. Please try again.';
      });
    }
  }

  void _copySecretKey() {
    Clipboard.setData(ClipboardData(text: _secret));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Secret key copied to clipboard'),
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  Widget _buildQrCode() {
    // ADD THIS CHECK
    if (_otpauthUri.isEmpty || _secret.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 32,
              color: AppColors.error,
            ),
            const SizedBox(height: 8),
            const Text(
              'No account found\nfor this email',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.error),
            ),
          ],
        ),
      );
    }

    try {
      final qrCode = QrCode.fromData(
        data: _otpauthUri,
        errorCorrectLevel: QrErrorCorrectLevel.H,
      );
      return PrettyQrView(qrImage: QrImage(qrCode));
    } catch (e) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 32,
              color: AppColors.error,
            ),
            const SizedBox(height: 8),
            const Text(
              'QR Code Error',
              style: TextStyle(fontSize: 12, color: AppColors.error),
            ),
          ],
        ),
      );
    }
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
            // Title
            Text(
              widget.setupMode
                  ? 'Setup Google Authenticator'
                  : 'Verify Google Authenticator',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),

            const SizedBox(height: 12),

            // Subtitle
            Text(
              widget.setupMode
                  ? 'Scan the QR code with Google Authenticator app to set up 2FA.'
                  : 'Enter the 6-digit code from your Google Authenticator app.',
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),

            const SizedBox(height: 32),

            if (widget.setupMode)
              // QR Code Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Real Scannable QR Code
                    Container(
                      width: 220,
                      height: 220,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _setupLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _buildQrCode(),
                    ),

                    const SizedBox(height: 16),

                    // Instructions
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: const Text(
                              'Scan this QR code with Google Authenticator app',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Secret Key (backup)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Manual Entry Key (Backup)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _secret,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'Courier',
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _copySecretKey,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.copy_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            if (widget.setupMode) ...[
              const SizedBox(height: 32),
              // Info Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: const Text(
                        'Save your backup codes in a safe place. You\'ll need them if you lose access to your authenticator.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Enter Code Section
            const Text(
              'Verify Your Code',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),

            const SizedBox(height: 12),

            // Error message
            if (_error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            if (_error != null) const SizedBox(height: 12),

            // Code Input
            TextField(
              controller: _codeCtrl,
              maxLength: 6,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              enabled: !_verifying,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: 8,
              ),
              decoration: InputDecoration(
                hintText: '000000',
                hintStyle: TextStyle(
                  fontSize: 20,
                  color: AppColors.textMuted.withOpacity(0.3),
                  letterSpacing: 4,
                ),
                counterText: '',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (_) {
                if (_error != null) {
                  setState(() => _error = null);
                }
              },
            ),

            const SizedBox(height: 12),

            const Text(
              'Enter the 6-digit code from your authenticator app',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),

            const SizedBox(height: 32),

            // Verify Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _verifying ? null : _verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                child: _verifying
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Verify Code',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
