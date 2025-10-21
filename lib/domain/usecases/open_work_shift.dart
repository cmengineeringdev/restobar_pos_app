import '../entities/work_shift.dart';
import '../repositories/work_shift_repository.dart';

class OpenWorkShift {
  final WorkShiftRepository repository;

  OpenWorkShift(this.repository);

  Future<WorkShift> call({
    required int pointOfSaleId,
    String? userId,
  }) async {
    return await repository.openWorkShift(pointOfSaleId, userId);
  }
}

