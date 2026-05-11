import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/provider_model.dart';
import '../services/auth_service.dart';

class ApiService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<ProviderModel>> getProviders() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.providersEndpoint}'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw Exception('Unexpected providers response from server.');
      }

      return decoded
          .whereType<Map>()
          .map((json) => ProviderModel.fromJson(
                Map<String, dynamic>.from(json),
              ))
          .toList();
    }

    if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please login again.');
    }

    throw Exception('Failed to load providers: ${response.statusCode}');
  }

  Future<bool> updateProviderStatus(int providerId, String status) async {
    final response = await http.patch(
      Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.providersEndpoint}$providerId/',
      ),
      headers: await _getHeaders(),
      body: jsonEncode({'verification_status': status}),
    );

    return response.statusCode == 200;
  }
}
