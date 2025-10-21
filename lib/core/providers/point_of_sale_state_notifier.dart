import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/point_of_sale.dart';
import '../../domain/usecases/clear_point_of_sale.dart';
import '../../domain/usecases/get_points_of_sale.dart';
import '../../domain/usecases/get_selected_point_of_sale.dart';
import '../../domain/usecases/select_point_of_sale.dart';
import 'providers.dart';

/// Estado del punto de venta
class PointOfSaleState {
  final List<PointOfSale> availablePointsOfSale;
  final PointOfSale? selectedPointOfSale;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const PointOfSaleState({
    this.availablePointsOfSale = const [],
    this.selectedPointOfSale,
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  PointOfSaleState copyWith({
    List<PointOfSale>? availablePointsOfSale,
    PointOfSale? selectedPointOfSale,
    bool? isLoading,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearSelected = false,
  }) {
    return PointOfSaleState(
      availablePointsOfSale:
          availablePointsOfSale ?? this.availablePointsOfSale,
      selectedPointOfSale:
          clearSelected ? null : (selectedPointOfSale ?? this.selectedPointOfSale),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

/// Notificador de estado del punto de venta
class PointOfSaleStateNotifier extends StateNotifier<PointOfSaleState> {
  final GetPointsOfSale _getPointsOfSale;
  final SelectPointOfSale _selectPointOfSale;
  final GetSelectedPointOfSale _getSelectedPointOfSale;
  final ClearPointOfSale _clearPointOfSale;

  PointOfSaleStateNotifier(
    this._getPointsOfSale,
    this._selectPointOfSale,
    this._getSelectedPointOfSale,
    this._clearPointOfSale,
  ) : super(const PointOfSaleState());

  /// Cargar puntos de venta disponibles
  Future<void> loadPointsOfSale() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final pointsOfSale = await _getPointsOfSale();
      state = state.copyWith(
        availablePointsOfSale: pointsOfSale,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar los puntos de venta: ${e.toString().replaceAll('Exception: ', '')}',
      );
    }
  }

  /// Seleccionar un punto de venta
  Future<void> selectPointOfSale(PointOfSale pointOfSale) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);

    try {
      await _selectPointOfSale(pointOfSale);
      state = state.copyWith(
        selectedPointOfSale: pointOfSale,
        isLoading: false,
        successMessage: 'Punto de venta seleccionado: ${pointOfSale.name}',
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// Cargar punto de venta seleccionado
  Future<void> loadSelectedPointOfSale() async {
    try {
      final selected = await _getSelectedPointOfSale();
      state = state.copyWith(selectedPointOfSale: selected);
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Limpiar punto de venta seleccionado
  Future<void> clearSelectedPointOfSale() async {
    try {
      await _clearPointOfSale();
      state = state.copyWith(clearSelected: true);
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Limpiar mensajes
  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}

/// Provider del notificador de punto de venta
final pointOfSaleStateProvider =
    StateNotifierProvider<PointOfSaleStateNotifier, PointOfSaleState>((ref) {
  final getPointsOfSale = ref.watch(getPointsOfSaleProvider);
  final selectPointOfSale = ref.watch(selectPointOfSaleProvider);
  final getSelectedPointOfSale = ref.watch(getSelectedPointOfSaleProvider);
  final clearPointOfSale = ref.watch(clearPointOfSaleProvider);
  return PointOfSaleStateNotifier(
    getPointsOfSale,
    selectPointOfSale,
    getSelectedPointOfSale,
    clearPointOfSale,
  );
});

