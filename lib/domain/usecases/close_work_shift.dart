import '../entities/work_shift.dart';
import '../repositories/work_shift_repository.dart';

class CloseWorkShift {
  final WorkShiftRepository repository;

  CloseWorkShift(this.repository);

  Future<WorkShift> call({
    required int remoteId,
    required int localId,
    required int pointOfSaleId,
  }) async {
    return await repository.closeWorkShift(remoteId, localId, pointOfSaleId);
  }
}

