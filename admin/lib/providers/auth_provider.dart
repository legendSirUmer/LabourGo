import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

enum AuthStatus { idle, loading, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus status = AuthStatus.idle;
  String errorMessage = '';
  String userName = 'Admin';

  // ── App start pe token check ─────────────────────────────
  Future<void> checkAuth() async {
    status = AuthStatus.idle;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      print('>>> CHECK AUTH token: "$token"');
      status = token.isNotEmpty
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    } catch (e) {
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ── Login ─────────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    status = AuthStatus.loading;
    errorMessage = '';
    notifyListeners();

    try {
      final data = await ApiService.login(email, password);
      print('>>> AUTH PROVIDER data: $data');

      // Backend response:
      // { "message": "...", "user": {...}, "tokens": { "access": "...", "refresh": "..." } }
      final tokens = data['tokens'];

      if (tokens != null && tokens['access'] != null) {
        // Token save karo
        await ApiService.saveToken(tokens['access']);

        // Refresh token bhi save karo (logout ke liye)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('refresh_token', tokens['refresh'] ?? '');

        // User name save karo
        final user = data['user'];
        userName = user?['full_name'] ?? user?['email'] ?? 'Admin';

        // Sirf admin/superuser ko allow karo
        final role = user?['role'] ?? '';
        if (role != 'admin' &&
            role != 'superuser' &&
            !(user?['is_staff'] == true) &&
            !(user?['is_superuser'] == true)) {
          // Uncomment karo agar sirf admins ko allow karna ho:
          // errorMessage = 'Admin access only.';
          // status = AuthStatus.unauthenticated;
          // notifyListeners();
          // return false;
        }

        status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }

      // Login failed — error message set karo
      errorMessage = data['error'] ??
          data['detail'] ??
          data['message'] ??
          'Login failed. Check your credentials.';
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      print('>>> LOGIN EXCEPTION: $e');
      errorMessage =
          'Cannot connect to server.\nMake sure Django is running on port 8000.';
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────────
  Future<void> logout() async {
    await ApiService.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('refresh_token');
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
