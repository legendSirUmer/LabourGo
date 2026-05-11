import 'package:flutter/foundation.dart';

class ApiConstants {
  // Override with:
  // flutter run --dart-define=API_BASE_URL=http://192.168.1.5:8000/api
  static const String configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  static String get baseUrl {
    if (configuredBaseUrl.isNotEmpty) return configuredBaseUrl;
    if (kIsWeb) return 'http://127.0.0.1:8000/api';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000/api';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return 'http://127.0.0.1:8000/api';
    }
  }

  // Endpoints
  static const String loginEndpoint = '/auth/login/';
  static const String logoutEndpoint = '/auth/logout/';
  static const String providersEndpoint = '/providers/';
  static const String profileEndpoint = '/auth/profile/';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
}
