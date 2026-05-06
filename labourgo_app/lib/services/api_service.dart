import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000/api";

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
      throw Exception(
        'Failed to load providers (${response.statusCode}).',
      );
    }

    if (response.body.isEmpty) {
      throw Exception('Empty response from server');
    }

    final decoded = json.decode(response.body);
    if (decoded is! List) {
      throw Exception('Unexpected response from server');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
  }

  static Future<List<Map<String, dynamic>>> fetchServiceCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/bookings/categories/'),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load categories (${response.statusCode}).',
      );
    }

    if (response.body.isEmpty) {
      throw Exception('Empty response from server');
    }

    final decoded = json.decode(response.body);
    if (decoded is! List) {
      throw Exception('Unexpected response from server');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
  }

  static Future<List<Map<String, dynamic>>> fetchCities() async {
    final response = await http.get(
      Uri.parse('$baseUrl/providers/cities/'),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load cities (${response.statusCode}).',
      );
    }

    if (response.body.isEmpty) {
      throw Exception('Empty response from server');
    }

    final decoded = json.decode(response.body);
    if (decoded is! List) {
      throw Exception('Unexpected response from server');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
  }

  static Future<Map<String, dynamic>?> findProviderByEmailPhone(
    String email,
    String phone,
  ) async {
    final providers = await fetchProviders();
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    for (final item in providers) {
      final providerEmail =
          (item['email'] ?? '').toString().trim().toLowerCase();
      final providerPhone =
          (item['phone'] ?? '').toString().replaceAll(RegExp(r'[^0-9]'), '');

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
    File? image,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl/providers/"),
    );

    data.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', image.path),
      );
    }

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

  // =========================
  // PROVIDERS
  // =========================
  static Future<Map<String, dynamic>> getProviderById(int providerId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/providers/$providerId/"),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load provider (${response.statusCode}).',
      );
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

    request.files.add(
      await http.MultipartFile.fromPath('image', image.path),
    );

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
      throw Exception(
        'Failed to load certificates (${response.statusCode}).',
      );
    }

    if (response.body.isEmpty) {
      return [];
    }

    final decoded = json.decode(response.body);
    if (decoded is! List) {
      throw Exception('Unexpected response from server');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
  }

  static Future<Map<String, dynamic>> createProviderCertificate(
    int providerId, {
    required Map<String, String> data,
    required File image,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl/providers/$providerId/certificates/"),
    );

    data.forEach((key, value) {
      request.fields[key] = value;
    });

    request.files.add(
      await http.MultipartFile.fromPath('image', image.path),
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
      throw Exception(
        'Failed to load performance (${response.statusCode}).',
      );
    }

    if (response.body.isEmpty) {
      throw Exception('Empty response from server');
    }

    return _decodeMap(response.body);
  }

  static Future<Map<String, dynamic>> toggleAvailability(
    int providerId,
  ) async {
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
    return _postJson('/auth/login/', {
      'email': email,
      'password': password,
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
    return {
      'error': 'Social login is not configured yet.'
    };
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
}
