import '../repositories/table_repository.dart';

class CreateTablesForPointOfSale {
  final TableRepository repository;

  CreateTablesForPointOfSale(this.repository);

  Future<void> call(int pointOfSaleId, int numberOfTables) async {
    return await repository.createTablesForPointOfSale(
        pointOfSaleId, numberOfTables);
  }
}


