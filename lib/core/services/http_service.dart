import 'package:http/http.dart' as http;
import 'storage_service.dart';

/// Authenticated HTTP Client that automatically adds Authorization header
class AuthenticatedHttpClient extends http.BaseClient {
  final http.Client _inner;
  final StorageService _storageService;

  AuthenticatedHttpClient(this._inner, this._storageService);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Get access token
    final token = _storageService.getAccessToken();

    // Add Authorization header if token exists
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Send request
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
  }
}
