/// Excepción cuando el token de acceso ha expirado
class TokenExpiredException implements Exception {
  final String message;

  TokenExpiredException([this.message = 'El token de acceso ha expirado']);

  @override
  String toString() => message;
}

/// Excepción cuando el usuario no está autorizado
class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException([this.message = 'No autorizado. Por favor inicie sesión nuevamente']);

  @override
  String toString() => message;
}

