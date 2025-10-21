import '../repositories/table_repository.dart';

class UpdateTableStatus {
  final TableRepository repository;

  UpdateTableStatus(this.repository);

  Future<void> call(int tableId, String status) async {
    return await repository.updateTableStatus(tableId, status);
  }
}


