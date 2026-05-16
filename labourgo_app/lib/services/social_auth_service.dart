import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SocialAuthPayload {
  const SocialAuthPayload({
    required this.provider,
    this.idToken,
    this.accessToken,
    this.email,
    this.fullName,
  });

  final String provider;
  final String? idToken;
  final String? accessToken;
  final String? email;
  final String? fullName;
}

class SocialAuthService {
  static bool _googleInitialized = false;

  // -------------------------
  // GOOGLE INIT (SAFE)
  // -------------------------
  static Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;

    final googleClientId =
        const String.fromEnvironment('GOOGLE_CLIENT_ID', defaultValue: '');

    final googleServerClientId =
        const String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID', defaultValue: '');

    await GoogleSignIn.instance.initialize(
      clientId: googleClientId.isEmpty ? null : googleClientId,
      serverClientId:
          googleServerClientId.isEmpty ? null : googleServerClientId,
    );

    _googleInitialized = true;
  }

  // -------------------------
  // GOOGLE SIGN IN
  // -------------------------
  static Future<SocialAuthPayload> signInWithGoogle() async {
    await _ensureGoogleInitialized();

    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw Exception('Google sign-in is not supported on this platform.');
    }

    final GoogleSignInAccount user =
        await GoogleSignIn.instance.authenticate();

    final String? idToken = user.authentication.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw Exception(
        'Google did not return an ID token. Check Google configuration.',
      );
    }

    return SocialAuthPayload(
      provider: 'google',
      idToken: idToken,
      email: user.email,
      fullName: user.displayName,
    );
  }

  // -------------------------
  // APPLE SIGN IN
  // -------------------------
  static Future<SocialAuthPayload> signInWithApple() async {
    final bool available = await SignInWithApple.isAvailable();

    if (!available) {
      throw Exception('Apple sign-in is not available on this device.');
    }

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: const [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final String? idToken = credential.identityToken;

    if (idToken == null || idToken.isEmpty) {
      throw Exception('Apple did not return an identity token.');
    }

    final parts = <String>[
      credential.givenName ?? '',
      credential.familyName ?? '',
    ]..removeWhere((e) => e.trim().isEmpty);

    return SocialAuthPayload(
      provider: 'apple',
      idToken: idToken,
      email: credential.email,
      fullName: parts.isEmpty ? null : parts.join(' '),
    );
  }

  // -------------------------
  // FACEBOOK SIGN IN
  // -------------------------
  static Future<SocialAuthPayload> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status != LoginStatus.success) {
      if (result.status == LoginStatus.cancelled) {
        throw Exception('Facebook sign-in cancelled.');
      }
      throw Exception(result.message ?? 'Facebook sign-in failed.');
    }

    final accessToken = result.accessToken?.tokenString;

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Facebook did not return an access token.');
    }

    String? email;
    String? name;

    try {
      final data = await FacebookAuth.instance.getUserData(
        fields: 'name,email',
      );
      email = data['email'] as String?;
      name = data['name'] as String?;
    } catch (_) {
      // Safe fallback
    }

    return SocialAuthPayload(
      provider: 'facebook',
      accessToken: accessToken,
      email: email,
      fullName: name,
    );
  }
}