class ApiConstants {
  // Base URL
  static const String baseUrl = 'http://localhost:5131';

  // Endpoints
  static const String productsEndpoint = '/api/product';

  // Full URLs
  static String get productsUrl => '$baseUrl$productsEndpoint';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Headers
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
}
