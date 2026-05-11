import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../models/user_model.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = _decodeResponse(response.body);

      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': _errorMessage(data, fallback: 'Login failed'),
        };
      }

      final accessToken = _accessTokenFrom(data);
      final refreshToken = _refreshTokenFrom(data);
      final userData = data['user'];

      if (accessToken == null) {
        return {
          'success': false,
          'message': 'Login succeeded but no access token was returned.',
        };
      }

      if (userData is! Map) {
        return {
          'success': false,
          'message': 'Login succeeded but no user profile was returned.',
        };
      }

      final user = UserModel.fromJson(Map<String, dynamic>.from(userData));
      if (!user.isAdmin) {
        await _clearStorage();
        return {
          'success': false,
          'message': 'Only admin accounts can access this dashboard.',
        };
      }

      await _saveTokens(accessToken: accessToken, refreshToken: refreshToken);
      await _saveUser(user);

      return {'success': true, 'data': data, 'user': user};
    } catch (_) {
      return {
        'success': false,
        'message': 'Network error. Check your connection.',
      };
    }
  }

  Future<void> logout() async {
    final accessToken = await getToken();
    final refreshToken = await getRefreshToken();

    if (accessToken != null && refreshToken != null) {
      try {
        await http.post(
          Uri.parse('${ApiConstants.baseUrl}${ApiConstants.logoutEndpoint}'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'refresh': refreshToken}),
        );
      } catch (_) {
        // Local logout should still succeed if the backend is unavailable.
      }
    }

    await _clearStorage();
  }

  Future<void> _saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConstants.tokenKey, accessToken);
    if (refreshToken != null) {
      await prefs.setString(ApiConstants.refreshTokenKey, refreshToken);
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiConstants.tokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiConstants.refreshTokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<bool> validateToken() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return false;

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profileEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = _decodeResponse(response.body);
        final user = UserModel.fromJson(data);
        if (!user.isAdmin) {
          await _clearStorage();
          return false;
        }

        await _saveUser(user);
        return true;
      }
    } catch (_) {
      // Fall through and clear stale local auth state.
    }

    await _clearStorage();
    return false;
  }

  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConstants.userKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(ApiConstants.userKey);
    if (userJson == null) return null;

    try {
      final decoded = jsonDecode(userJson);
      if (decoded is Map) {
        return UserModel.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      await _clearStorage();
    }

    return null;
  }

  Future<void> _clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConstants.tokenKey);
    await prefs.remove(ApiConstants.refreshTokenKey);
    await prefs.remove(ApiConstants.userKey);
  }

  Map<String, dynamic> _decodeResponse(String body) {
    if (body.isEmpty) return {};

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);

    return {'message': 'Unexpected response from server.'};
  }

  String _errorMessage(
    Map<String, dynamic> data, {
    required String fallback,
  }) {
    return _stringValue(data['detail']) ??
        _stringValue(data['message']) ??
        _stringValue(data['error']) ??
        fallback;
  }

  String? _accessTokenFrom(Map<String, dynamic> data) {
    return _stringValue(data['token']) ??
        _stringValue(data['access']) ??
        _stringValueFromMap(data['tokens'], 'access');
  }

  String? _refreshTokenFrom(Map<String, dynamic> data) {
    return _stringValue(data['refresh']) ??
        _stringValueFromMap(data['tokens'], 'refresh');
  }

  String? _stringValueFromMap(Object? value, String key) {
    if (value is! Map) return null;
    return _stringValue(value[key]);
  }

  String? _stringValue(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
