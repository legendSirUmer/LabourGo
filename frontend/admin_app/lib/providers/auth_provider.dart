import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String _errorMessage = '';

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> checkAuthStatus() async {
    try {
      final loggedIn = await _authService.isLoggedIn();
      if (!loggedIn) {
        _setUnauthenticated();
        return;
      }

      final valid = await _authService.validateToken();
      if (!valid) {
        _setUnauthenticated();
        return;
      }

      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null || !currentUser.isAdmin) {
        _setUnauthenticated();
        return;
      }

      _user = currentUser;
      _status = AuthStatus.authenticated;
      _errorMessage = '';
      notifyListeners();
    } catch (_) {
      _setUnauthenticated();
    }
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    final result = await _authService.login(email, password);

    if (result['success'] == true) {
      final resultUser = result['user'];
      _user = resultUser is UserModel
          ? resultUser
          : await _authService.getCurrentUser();

      if (_user == null || !_user!.isAdmin) {
        _errorMessage = 'Only admin accounts can access this dashboard.';
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    }

    _user = null;
    _errorMessage = (result['message'] ?? 'Login failed').toString();
    _status = AuthStatus.error;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await _authService.logout();
    _setUnauthenticated();
  }

  void _setUnauthenticated() {
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
