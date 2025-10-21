import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/work_shift.dart';
import '../../domain/usecases/get_active_work_shift.dart';
import '../../domain/usecases/open_work_shift.dart';
import '../../domain/usecases/close_work_shift.dart';
import 'providers.dart';

/// Estado de los turnos de trabajo
class WorkShiftState {
  final WorkShift? activeWorkShift;
  final bool isLoading;
  final String? error;
  final bool hasActiveShift;

  const WorkShiftState({
    this.activeWorkShift,
    this.isLoading = false,
    this.error,
    this.hasActiveShift = false,
  });

  WorkShiftState copyWith({
    WorkShift? activeWorkShift,
    bool? isLoading,
    String? error,
    bool? hasActiveShift,
    bool clearError = false,
    bool clearActiveShift = false,
  }) {
    return WorkShiftState(
      activeWorkShift: clearActiveShift
          ? null
          : (activeWorkShift ?? this.activeWorkShift),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      hasActiveShift: hasActiveShift ?? this.hasActiveShift,
    );
  }
}

/// Notificador de estado de turnos de trabajo
class WorkShiftStateNotifier extends StateNotifier<WorkShiftState> {
  final GetActiveWorkShift _getActiveWorkShift;
  final OpenWorkShift _openWorkShift;
  final CloseWorkShift _closeWorkShift;

  WorkShiftStateNotifier(
    this._getActiveWorkShift,
    this._openWorkShift,
    this._closeWorkShift,
  ) : super(const WorkShiftState());

  /// Verificar si hay un turno activo en remoto
  Future<void> checkActiveWorkShiftRemote(int pointOfSaleId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final workShift = await _getActiveWorkShift.fromRemote(pointOfSaleId);

      state = state.copyWith(
        activeWorkShift: workShift,
        hasActiveShift: workShift != null,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
        hasActiveShift: false,
      );
      rethrow;
    }
  }

  /// Verificar si hay un turno activo en local
  Future<void> checkActiveWorkShiftLocal() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final workShift = await _getActiveWorkShift.fromLocal();

      state = state.copyWith(
        activeWorkShift: workShift,
        hasActiveShift: workShift != null,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
        hasActiveShift: false,
      );
      rethrow;
    }
  }

  /// Abrir un nuevo turno
  Future<void> openWorkShift({
    required int pointOfSaleId,
    String? userId,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final workShift = await _openWorkShift(
        pointOfSaleId: pointOfSaleId,
        userId: userId,
      );

      state = state.copyWith(
        activeWorkShift: workShift,
        hasActiveShift: true,
        isLoading: false,
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

  /// Cerrar turno actual
  Future<void> closeWorkShift(int pointOfSaleId) async {
    print('DEBUG: closeWorkShift called with pointOfSaleId: $pointOfSaleId');
    print('DEBUG: activeWorkShift: ${state.activeWorkShift}');
    print('DEBUG: localId: ${state.activeWorkShift?.localId}');
    print('DEBUG: remoteId: ${state.activeWorkShift?.remoteId}');
    
    if (state.activeWorkShift?.localId == null || 
        state.activeWorkShift?.remoteId == null) {
      print('DEBUG: No hay turno activo con IDs válidos');
      state = state.copyWith(
        error: 'No hay turno activo para cerrar',
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    print('DEBUG: Estado cambiado a loading');

    try {
      print('DEBUG: Llamando a _closeWorkShift use case');
      final closedWorkShift = await _closeWorkShift(
        remoteId: state.activeWorkShift!.remoteId!,
        localId: state.activeWorkShift!.localId!,
        pointOfSaleId: pointOfSaleId,
      );

      print('DEBUG: Turno cerrado exitosamente: $closedWorkShift');
      state = state.copyWith(
        activeWorkShift: closedWorkShift,
        hasActiveShift: false,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      print('DEBUG: Error al cerrar turno: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// Establecer turno activo manualmente
  void setActiveWorkShift(WorkShift? workShift) {
    state = state.copyWith(
      activeWorkShift: workShift,
      hasActiveShift: workShift != null,
    );
  }

  /// Limpiar error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Reset state
  void reset() {
    state = const WorkShiftState();
  }
}

/// Provider del notificador de turnos de trabajo
final workShiftStateProvider =
    StateNotifierProvider<WorkShiftStateNotifier, WorkShiftState>((ref) {
  final getActiveWorkShift = ref.watch(getActiveWorkShiftProvider);
  final openWorkShift = ref.watch(openWorkShiftProvider);
  final closeWorkShift = ref.watch(closeWorkShiftProvider);
  return WorkShiftStateNotifier(
      getActiveWorkShift, openWorkShift, closeWorkShift);
});

