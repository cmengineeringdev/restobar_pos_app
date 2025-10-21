import '../entities/work_shift.dart';

abstract class WorkShiftRepository {
  /// Get active work shift from remote API
  Future<WorkShift?> getActiveWorkShiftRemote(int pointOfSaleId);

  /// Get active work shift from local database
  Future<WorkShift?> getActiveWorkShiftLocal();

  /// Open a new work shift (both remote and local)
  Future<WorkShift> openWorkShift(int pointOfSaleId, String? userId);

  /// Close work shift (both remote and local)
  Future<WorkShift> closeWorkShift(int remoteId, int localId, int pointOfSaleId);

  /// Get all work shifts from local database
  Future<List<WorkShift>> getAllWorkShiftsLocal();
}

