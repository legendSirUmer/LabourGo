import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get baseUrl =>
      kIsWeb ? 'http://127.0.0.1:8000' : 'http://10.0.2.2:8000';

  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // LOGIN
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));
      print('>>> LOGIN ${res.statusCode}: ${res.body}');
      return jsonDecode(res.body);
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // STATS
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/auth/admin/stats/'),
        headers: await _headers(),
      ).timeout(const Duration(seconds: 10));
      print('>>> STATS ${res.statusCode}: ${res.body}');
      if (res.statusCode == 200) return jsonDecode(res.body);
      return {};
    } catch (e) {
      print('>>> STATS ERROR: $e');
      return {};
    }
  }

  // PROVIDERS — correct URL: /api/providers/
  static Future<List<dynamic>> getProviders({String? status}) async {
    try {
      final query = (status != null && status != 'all') ? '?verification_status=$status' : '';
      final res = await http.get(
        Uri.parse('$baseUrl/api/providers/$query'),
        headers: await _headers(),
      ).timeout(const Duration(seconds: 10));
      print('>>> PROVIDERS ${res.statusCode}: ${res.body.substring(0, res.body.length.clamp(0, 200))}');
      if (res.statusCode == 200) return jsonDecode(res.body);
      return [];
    } catch (e) {
      print('>>> PROVIDERS ERROR: $e');
      return [];
    }
  }

  static Future<bool> updateProviderStatus(int id, String status) async {
    try {
      final res = await http.patch(
        Uri.parse('$baseUrl/api/providers/$id/'),
        headers: await _headers(),
        body: jsonEncode({'verification_status': status}),
      ).timeout(const Duration(seconds: 10));
      print('>>> UPDATE PROVIDER ${res.statusCode}: ${res.body}');
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // USERS
  static Future<List<dynamic>> getUsers() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/auth/admin/users/'),
        headers: await _headers(),
      ).timeout(const Duration(seconds: 10));
      print('>>> USERS ${res.statusCode}: ${res.body.substring(0, res.body.length.clamp(0, 200))}');
      if (res.statusCode == 200) return jsonDecode(res.body);
      return [];
    } catch (e) {
      print('>>> USERS ERROR: $e');
      return [];
    }
  }

  static Future<bool> toggleUserBan(int id) async {
    try {
      final res = await http.patch(
        Uri.parse('$baseUrl/api/auth/admin/users/$id/toggle/'),
        headers: await _headers(),
      ).timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // BOOKINGS
  static Future<List<dynamic>> getAllBookings() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/bookings/my-bookings/'),
        headers: await _headers(),
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) return jsonDecode(res.body);
      return [];
    } catch (e) {
      return [];
    }
  }

  // PAYMENTS
  static Future<List<dynamic>> getAllPayments() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/payments/my-payments/'),
        headers: await _headers(),
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) return jsonDecode(res.body);
      return [];
    } catch (e) {
      return [];
    }
  }
}