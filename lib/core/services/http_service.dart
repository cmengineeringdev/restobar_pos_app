import 'package:http/http.dart' as http;
import 'storage_service.dart';
import 'session_manager.dart';
import '../exceptions/auth_exceptions.dart';

/// Authenticated HTTP Client that automatically adds Authorization header
/// and handles token expiration and 401 responses
class AuthenticatedHttpClient extends http.BaseClient {
  final http.Client _inner;
  final StorageService _storageService;
  final SessionManager _sessionManager;

  AuthenticatedHttpClient(
    this._inner,
    this._storageService,
    this._sessionManager,
  );

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    try {
      // Validar si el token ha expirado antes de hacer la petición
      if (_storageService.isLoggedIn()) {
        _sessionManager.validateTokenBeforeRequest();
      }

      // Get access token
      final token = _storageService.getAccessToken();

      // Add Authorization header if token exists
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Send request
      final response = await _inner.send(request);

      // Verificar si la respuesta es 401 (No autorizado)
      if (response.statusCode == 401) {
        // Cerrar sesión automáticamente
        await _sessionManager.handle401Response();
      }

      return response;
    } on TokenExpiredException {
      // El token ha expirado, cerrar sesión automáticamente
      await _sessionManager.handleSessionExpired();
      rethrow;
    } on UnauthorizedException {
      // Ya fue manejado en handle401Response
      rethrow;
    }
  }

  @override
  void close() {
    _inner.close();
  }
}
