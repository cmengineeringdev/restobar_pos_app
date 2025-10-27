import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

/// Helper para mostrar mensajes consistentes en toda la aplicación
class MessageHelper {
  /// Mostrar mensaje de éxito
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    _showMessage(
      context,
      message: message,
      backgroundColor: AppTheme.successColor,
      duration: duration ?? const Duration(seconds: 2),
      action: action,
    );
  }

  /// Mostrar mensaje de error
  static void showError(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    _showMessage(
      context,
      message: message,
      backgroundColor: AppTheme.errorColor,
      duration: duration ?? const Duration(seconds: 5),
      action: action,
    );
  }

  /// Mostrar mensaje de advertencia
  static void showWarning(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    _showMessage(
      context,
      message: message,
      backgroundColor: AppTheme.warningColor,
      duration: duration ?? const Duration(seconds: 3),
      action: action,
    );
  }

  /// Mostrar mensaje de información
  static void showInfo(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    _showMessage(
      context,
      message: message,
      backgroundColor: AppTheme.primaryColor,
      duration: duration ?? const Duration(seconds: 2),
      action: action,
    );
  }

  /// Método privado para mostrar el SnackBar
  /// Limpia los mensajes anteriores antes de mostrar el nuevo
  static void _showMessage(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required Duration duration,
    SnackBarAction? action,
  }) {
    // Limpiar todos los SnackBars anteriores para evitar el encolamiento
    ScaffoldMessenger.of(context).clearSnackBars();

    // Mostrar el nuevo mensaje
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        duration: duration,
        action: action,
      ),
    );
  }
}

/// Extensión para BuildContext para acceso más fácil a los mensajes
extension MessageExtension on BuildContext {
  /// Mostrar mensaje de éxito
  void showSuccess(String message, {Duration? duration, SnackBarAction? action}) {
    MessageHelper.showSuccess(this, message, duration: duration, action: action);
  }

  /// Mostrar mensaje de error
  void showError(String message, {Duration? duration, SnackBarAction? action}) {
    MessageHelper.showError(this, message, duration: duration, action: action);
  }

  /// Mostrar mensaje de advertencia
  void showWarning(String message, {Duration? duration, SnackBarAction? action}) {
    MessageHelper.showWarning(this, message, duration: duration, action: action);
  }

  /// Mostrar mensaje de información
  void showInfo(String message, {Duration? duration, SnackBarAction? action}) {
    MessageHelper.showInfo(this, message, duration: duration, action: action);
  }
}
