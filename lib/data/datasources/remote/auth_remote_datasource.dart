import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/auth_constants.dart';
import '../../models/auth_models.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginRequest request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client httpClient;

  AuthRemoteDataSourceImpl({required this.httpClient});

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final url =
          Uri.parse('${ApiConstants.baseUrl}${AuthConstants.loginEndpoint}');

      final response = await httpClient
          .post(
            url,
            headers: ApiConstants.headers,
            body: json.encode(request.toJson()),
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        final loginResponse = LoginResponse.fromJson(jsonResponse);

        if (loginResponse.success && loginResponse.data != null) {
          return loginResponse;
        } else {
          throw Exception(loginResponse.message);
        }
      } else if (response.statusCode == 401) {
        throw Exception('Usuario, contraseña o código de empresa inválido');
      } else if (response.statusCode == 400) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        throw Exception(jsonResponse['message'] ?? 'Bad request');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error: ${response.statusCode}');
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }
}
