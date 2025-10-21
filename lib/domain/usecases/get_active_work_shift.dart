import '../entities/work_shift.dart';
import '../repositories/work_shift_repository.dart';

class GetActiveWorkShift {
  final WorkShiftRepository repository;

  GetActiveWorkShift(this.repository);

  /// Get active work shift from remote API
  Future<WorkShift?> fromRemote(int pointOfSaleId) async {
    return await repository.getActiveWorkShiftRemote(pointOfSaleId);
  }

  /// Get active work shift from local database
  Future<WorkShift?> fromLocal() async {
    return await repository.getActiveWorkShiftLocal();
  }
}

