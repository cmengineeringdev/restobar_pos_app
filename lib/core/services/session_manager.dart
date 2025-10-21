import 'package:flutter/material.dart';
import '../exceptions/auth_exceptions.dart';
import 'storage_service.dart';

/// Gestor de sesión para manejar el cierre de sesión desde cualquier parte de la app
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  final StorageService _storageService = StorageService();
  
  // Callback para navegar al login cuando la sesión expire
  VoidCallback? _onSessionExpired;
  
  // Global key para mostrar mensajes
  GlobalKey<ScaffoldMessengerState>? _scaffoldMessengerKey;

  /// Registrar callback para cuando la sesión expire
  void registerSessionExpiredCallback(VoidCallback callback) {
    _onSessionExpired = callback;
  }
  
  /// Registrar scaffold messenger key para mostrar mensajes
  void registerScaffoldMessengerKey(GlobalKey<ScaffoldMessengerState> key) {
    _scaffoldMessengerKey = key;
  }

  /// Verificar si el token ha expirado
  bool isTokenExpired() {
    final user = _storageService.getUser();
    if (user == null) return true;
    
    return user.isTokenExpired;
  }

  /// Verificar si hay token y no ha expirado
  bool hasValidToken() {
    final token = _storageService.getAccessToken();
    if (token == null || token.isEmpty) return false;
    
    return !isTokenExpired();
  }

  /// Manejar expiración de sesión (logout automático)
  Future<void> handleSessionExpired() async {
    await _storageService.clearUserData();
    
    // Mostrar mensaje al usuario
    _showSessionExpiredMessage();
    
    // Notificar que la sesión ha expirado
    if (_onSessionExpired != null) {
      _onSessionExpired!();
    }
  }

  /// Validar token antes de hacer una petición
  void validateTokenBeforeRequest() {
    if (isTokenExpired()) {
      throw TokenExpiredException();
    }
  }

  /// Manejar respuesta 401 de la API
  Future<void> handle401Response() async {
    await handleSessionExpired();
    throw UnauthorizedException();
  }
  
  /// Mostrar mensaje de sesión expirada
  void _showSessionExpiredMessage() {
    if (_scaffoldMessengerKey?.currentState != null) {
      _scaffoldMessengerKey!.currentState!.showSnackBar(
        const SnackBar(
          content: Text('Tu sesión ha expirado. Por favor inicia sesión nuevamente.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }
}

