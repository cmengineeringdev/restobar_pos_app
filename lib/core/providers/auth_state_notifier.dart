import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import 'providers.dart';

/// Estado de autenticación
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

/// Notificador de estado de autenticación
class AuthStateNotifier extends StateNotifier<AuthState> {
  final LoginUser _loginUser;
  final LogoutUser _logoutUser;
  final GetCurrentUser _getCurrentUser;

  AuthStateNotifier(this._loginUser, this._logoutUser, this._getCurrentUser)
      : super(const AuthState());

  /// Login del usuario
  Future<void> login(
      String username, String password, String companyCode) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _loginUser(username, password, companyCode);
      state = state.copyWith(
        user: user,
        isLoading: false,
        isAuthenticated: true,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
        isAuthenticated: false,
      );
      rethrow;
    }
  }

  /// Cargar usuario actual desde almacenamiento local
  Future<void> loadCurrentUser() async {
    try {
      final user = await _getCurrentUser();
      if (user != null) {
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
        );
      }
    } catch (e) {
      // Si hay error al cargar el usuario, simplemente no hacemos nada
      // El estado permanecerá con user = null
      print('Error al cargar usuario actual: $e');
    }
  }

  /// Logout del usuario
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _logoutUser();
      state = const AuthState(); // Reset to initial state
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// Logout forzado (sin estado de carga) - usado cuando el token expira o hay 401
  Future<void> forceLogout() async {
    try {
      await _logoutUser();
      state = const AuthState(); // Reset to initial state
    } catch (e) {
      // En caso de error, aún así limpiamos el estado
      state = const AuthState();
    }
  }

  /// Cargar usuario actual
  void setUser(User? user) {
    state = state.copyWith(
      user: user,
      isAuthenticated: user != null,
    );
  }

  /// Limpiar error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider del notificador de autenticación
final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final loginUser = ref.watch(loginUserProvider);
  final logoutUser = ref.watch(logoutUserProvider);
  final getCurrentUser = ref.watch(getCurrentUserProvider);
  return AuthStateNotifier(loginUser, logoutUser, getCurrentUser);
});

