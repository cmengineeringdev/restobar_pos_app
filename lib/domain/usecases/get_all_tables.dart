import '../entities/table.dart';
import '../repositories/table_repository.dart';

class GetAllTables {
  final TableRepository repository;

  GetAllTables(this.repository);

  Future<List<Table>> call(int pointOfSaleId) async {
    return await repository.getAllTables(pointOfSaleId);
  }
}


