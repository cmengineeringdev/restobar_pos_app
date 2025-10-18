class AuthConstants {
  // Storage keys
  static const String userDataKey = 'user_data';
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String isLoggedInKey = 'is_logged_in';

  // API endpoints
  static const String loginEndpoint = '/api/auth/login/account';
  static const String logoutEndpoint = '/api/auth/logout';
  static const String refreshTokenEndpoint = '/api/auth/refresh-token';
}
