import 'dart:convert';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../models/auth_models.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<User> login(
      String username, String password, String companyCode) async {
    // Create login request
    final request = LoginRequest(
      username: username,
      password: password,
      companyCode: companyCode,
    );

    // Call API
    final response = await remoteDataSource.login(request);

    if (response.data == null) {
      throw Exception('Invalid login response');
    }

    // Extract userId from JWT token
    final userId = _extractUserIdFromToken(response.data!.accessToken);

    // Convert to User entity
    final user = response.data!.toUser(username, companyCode, userId);

    // Save to local storage
    final userModel = UserModel.fromEntity(user);
    final saved = await localDataSource.saveUser(userModel);

    if (!saved) {
      throw Exception('Failed to save user data');
    }

    return user;
  }

  @override
  Future<User?> getCurrentUser() async {
    final userModel = localDataSource.getUser();
    return userModel?.toEntity();
  }

  @override
  bool isLoggedIn() {
    return localDataSource.isLoggedIn();
  }

  @override
  Future<bool> logout() async {
    return await localDataSource.logout();
  }

  /// Extract userId from JWT token
  String _extractUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return '1'; // Default userId
      }

      // Decode payload
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> payloadMap = json.decode(decoded);

      return payloadMap['userId']?.toString() ??
          payloadMap['sub']?.toString() ??
          '1';
    } catch (e) {
      return '1'; // Default userId if extraction fails
    }
  }
}
