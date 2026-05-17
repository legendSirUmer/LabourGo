import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String baseUrl = "https://kgz17l6w-8000.inc1.devtunnels.ms/api";

  // ── Save token locally ───────────────────────────────────
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('provider_id');
    await prefs.setBool('is_logged_in', false);
    await prefs.setBool('is_provider_signed_in', false);
  }

  // ── Headers ──────────────────────────────────────────────
  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static String get _apiRoot {
    if (baseUrl.endsWith('/api/')) {
      return baseUrl.substring(0, baseUrl.length - 5);
    }
    if (baseUrl.endsWith('/api')) {
      return baseUrl.substring(0, baseUrl.length - 4);
    }
    return baseUrl;
  }

  static String? resolveImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    if (path.startsWith('/')) return '$_apiRoot$path';
    return '$_apiRoot/$path';
  }

  // =========================
  // GET Providers
  // =========================
  static Future<List<Map<String, dynamic>>> fetchProviders() async {
    final response = await http.get(
      Uri.parse('$baseUrl/providers/'),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load providers (${response.statusCode}).');
    }

    if (response.body.isEmpty) {
      throw Exception('Empty response from server');
    }

    final decoded = json.decode(response.body);
    if (decoded is! List) {
      throw Exception('Unexpected response from server');
    }

    return decoded.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  static Future<List<Map<String, dynamic>>> fetchServiceCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/bookings/categories/'),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load categories (${response.statusCode}).');
    }

    if (response.body.isEmpty) {
      throw Exception('Empty response from server');
    }

    final decoded = json.decode(response.body);
    if (decoded is! List) {
      throw Exception('Unexpected response from server');
    }

    return decoded.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  static Future<List<Map<String, dynamic>>> fetchCities() async {
    final response = await http.get(
      Uri.parse('$baseUrl/providers/cities/'),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load cities (${response.statusCode}).');
    }

    if (response.body.isEmpty) {
      throw Exception('Empty response from server');
    }

    final decoded = json.decode(response.body);
    if (decoded is! List) {
      throw Exception('Unexpected response from server');
    }

    return decoded.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  static Future<List<dynamic>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/bookings/categories/'),
      headers: const {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load categories (${response.statusCode}).');
    }

    if (response.body.isEmpty) {
      return [];
    }

    return json.decode(response.body) as List<dynamic>;
  }

  static Future<List<dynamic>> getProviders() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/providers/'),
      headers: await _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load providers (${response.statusCode}).');
    }

    if (response.body.isEmpty) {
      return [];
    }

    return json.decode(response.body) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> createBooking({
    required int providerId,
    required int categoryId,
    required String description,
    required String locationAddress,
    required String scheduledDate,
    required String scheduledTime,
    required String priceOffered,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings/create/'),
      headers: await _authHeaders(),
      body: json.encode({
        'provider_id': providerId,
        'category_id': categoryId,
        'description': description,
        'location_address': locationAddress,
        'scheduled_date': scheduledDate,
        'scheduled_time': scheduledTime,
        'price_offered': priceOffered,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to create booking (${response.statusCode}).');
    }

    if (response.body.isEmpty) {
      return {};
    }

    return json.decode(response.body) as Map<String, dynamic>;
  }

  static Future<List<Map<String, dynamic>>> getMyBookings() async {
    final response = await http.get(
      Uri.parse('$baseUrl/bookings/my-bookings/'),
      headers: await _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load bookings (${response.statusCode}).');
    }

    if (response.body.isEmpty) {
      return [];
    }

    final List data = json.decode(response.body);

    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<Map<String, dynamic>> getBookingDetails(int bookingId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/bookings/$bookingId/'),
      headers: await _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load booking details (${response.statusCode}).',
      );
    }

    if (response.body.isEmpty) {
      return {};
    }

    return json.decode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getPaymentByBooking(int bookingId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/payments/booking/$bookingId/'),
      headers: await _authHeaders(),
    );

    if (response.statusCode == 404) {
      // No payment found for this booking
      return {};
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load payment details (${response.statusCode}).',
      );
    }

    if (response.body.isEmpty) {
      return {};
    }

    return json.decode(response.body) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getMyPayments() async {
    final response = await http.get(
      Uri.parse('$baseUrl/payments/my-payments/'),
      headers: await _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load payments (${response.statusCode}).');
    }

    if (response.body.isEmpty) {
      return [];
    }

    return json.decode(response.body) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> makePayment({
    required int bookingId,
    required String amount,
    required String method,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payments/pay/'),
      headers: await _authHeaders(),
      body: json.encode({
        'booking_id': bookingId,
        'amount': amount,
        'method': method,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to make payment (${response.statusCode}).');
    }

    if (response.body.isEmpty) {
      return {};
    }

    return json.decode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> submitReview({
    required int bookingId,
    required int rating,
    required String comment,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reviews/create/'),
      headers: await _authHeaders(),
      body: json.encode({
        'booking_id': bookingId,
        'rating': rating,
        'comment': comment,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to submit review (${response.statusCode}).');
    }

    if (response.body.isEmpty) {
      return {};
    }

    return json.decode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>?> findProviderByEmailPhone(
    String email,
    String phone,
  ) async {
    final providers = await fetchProviders();
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    for (final item in providers) {
      final providerEmail = (item['email'] ?? '')
          .toString()
          .trim()
          .toLowerCase();
      final providerPhone = (item['phone'] ?? '').toString().replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );

      if (providerEmail == normalizedEmail &&
          providerPhone == normalizedPhone) {
        return item;
      }
    }

    return null;
  }

  // =========================
  // CREATE Provider
  // =========================
  static Future<Map<String, dynamic>> createProvider({
    required Map<String, dynamic> data,
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/providers/'), // <-- was /providers/create/
    );

    data.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    if (imageBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: imageFileName ?? 'profile.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();

    print('CREATE PROVIDER STATUS: ${response.statusCode}'); // ADD THIS
    print('CREATE PROVIDER BODY: $body'); // ADD THIS

    return jsonDecode(body);
  }

  // =========================
  // PROVIDERS
  // =========================
  static Future<Map<String, dynamic>> getProviderById(int providerId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/providers/$providerId/"),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load provider (${response.statusCode}).');
    }

    if (response.body.isEmpty) {
      throw Exception('Empty response from server');
    }

    return _decodeMap(response.body);
  }

  static Future<Map<String, dynamic>> updateProvider(
    int providerId,
    Map<String, dynamic> data,
  ) async {
    final response = await http.patch(
      Uri.parse("$baseUrl/providers/$providerId/"),
      headers: const {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception(_formatError(response.body, response.statusCode));
    }

    if (response.body.isEmpty) {
      return {};
    }

    return _decodeMap(response.body);
  }

  static Future<Map<String, dynamic>> updateProviderImage(
    int providerId,
    File image,
  ) async {
    final request = http.MultipartRequest(
      'PATCH',
      Uri.parse("$baseUrl/providers/$providerId/"),
    );

    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_formatError(body, response.statusCode));
    }

    if (body.isEmpty) {
      return {};
    }

    return _decodeMap(body);
  }

  static Future<List<Map<String, dynamic>>> fetchProviderCertificates(
    int providerId,
  ) async {
    final response = await http.get(
      Uri.parse("$baseUrl/providers/$providerId/certificates/"),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load certificates (${response.statusCode}).');
    }

    if (response.body.isEmpty) {
      return [];
    }

    final decoded = json.decode(response.body);
    if (decoded is! List) {
      throw Exception('Unexpected response from server');
    }

    return decoded.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  static Future<Map<String, dynamic>> createProviderCertificate(
    int providerId, {
    required Map<String, String> data,
    required Uint8List imageBytes,
    String? imageName,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl/providers/$providerId/certificates/"),
    );

    // Add text fields
    data.forEach((key, value) {
      request.fields[key] = value;
    });

    // Add image from bytes
    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: imageName ?? 'certificate.jpg',
      ),
    );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 201) {
      throw Exception(_formatError(body, response.statusCode));
    }

    if (body.isEmpty) {
      return {};
    }

    return _decodeMap(body);
  }

  static Future<void> deleteProviderCertificate(
    int providerId,
    int certificateId,
  ) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/providers/$providerId/certificates/$certificateId/"),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 204) {
      throw Exception(_formatError(response.body, response.statusCode));
    }
  }

  static Future<Map<String, dynamic>> getProviderPerformance(
    int providerId,
  ) async {
    final response = await http.get(
      Uri.parse("$baseUrl/providers/$providerId/performance/"),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load performance (${response.statusCode}).');
    }

    if (response.body.isEmpty) {
      throw Exception('Empty response from server');
    }

    return _decodeMap(response.body);
  }

  static Future<Map<String, dynamic>> toggleAvailability(int providerId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/providers/$providerId/toggle_availability/"),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update availability (${response.statusCode}).',
      );
    }

    if (response.body.isEmpty) {
      throw Exception('Empty response from server');
    }

    return _decodeMap(response.body);
  }

  // =========================
  // LOGIN
  // =========================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return _postJson('/auth/login/', {'email': email, 'password': password});
  }

  static Future<Map<String, dynamic>> verifyTwoFactorLogin({
    required String challengeToken,
    required String otpCode,
  }) async {
    return _postJson('/auth/login/2fa/verify/', {
      'challenge_token': challengeToken,
      'otp_code': otpCode,
    });
  }

  static Future<Map<String, dynamic>> setupTwoFactor({
    required String email,
  }) async {
    return _postJson('/auth/2fa/setup/', {'email': email});
  }

  static Future<Map<String, dynamic>> loginWithTwoFactor({
    required String email,
    required String otpCode,
  }) async {
    return _postJson('/auth/2fa/login/', {'email': email, 'otp_code': otpCode});
  }

  static Future<Map<String, dynamic>> resetPasswordByContact({
    required String email,
    required String phone,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return _postJson('/auth/password-reset/by-contact/', {
      'email': email,
      'phone': phone,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
    });
  }

  // =========================
  // REGISTER
  // =========================
  static Future<Map<String, dynamic>> register({
    required String email,
    required String fullName,
    required String phone,
    required String password,
    String role = 'customer',
  }) async {
    return _postJson('/auth/register/', {
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'role': role,
      'password': password,
    });
  }

  // =========================
  // SOCIAL LOGIN (placeholder)
  // =========================
  static Future<Map<String, dynamic>> socialLogin({
    required String provider,
    String? idToken,
    String? accessToken,
    String? email,
    String? fullName,
  }) async {
    return {'error': 'Social login is not configured yet.'};
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/profile/'),
      headers: await _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load profile (${response.statusCode}).');
    }

    if (response.body.isEmpty) {
      return {};
    }

    return json.decode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/auth/profile/'),
      headers: await _authHeaders(),
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile (${response.statusCode}).');
    }

    if (response.body.isEmpty) {
      return {'status': 'success', 'message': 'Profile updated.'};
    }

    return json.decode(response.body) as Map<String, dynamic>;
  }

  // =========================
  // COMMON POST METHOD
  // =========================
  static Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: const {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.body.isEmpty) {
      return {'error': 'Empty response from server.'};
    }

    final decoded = json.decode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return {'error': 'Unexpected response from server.'};
  }

  static Map<String, dynamic> _decodeMap(String body) {
    final decoded = json.decode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return {'data': decoded};
  }

  static String _formatError(String body, int statusCode) {
    if (body.isEmpty) {
      return 'Request failed ($statusCode).';
    }

    try {
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded.entries
            .map((entry) => '${entry.key}: ${entry.value}')
            .join(', ');
      }
    } catch (_) {}

    return 'Request failed ($statusCode): $body';
  }

  static Future<Map<String, dynamic>> updateBookingStatus(
    int bookingId,
    String status,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/bookings/$bookingId/update/'), // <-- add /update/
      headers: await _authHeaders(),
      body: json.encode({'status': status}),
    );

    print('UPDATE STATUS: ${response.statusCode}');
    print('UPDATE BODY: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to update booking (${response.statusCode}).');
    }

    return json.decode(response.body) as Map<String, dynamic>;
  }
}
