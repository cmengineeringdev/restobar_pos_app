import '../../domain/entities/table.dart';
import '../../domain/repositories/table_repository.dart';
import '../datasources/local/table_local_datasource.dart';

class TableRepositoryImpl implements TableRepository {
  final TableLocalDataSource localDataSource;

  TableRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Table>> getAllTables(int pointOfSaleId) async {
    try {
      final tableModels = await localDataSource.getAllTables(pointOfSaleId);
      return tableModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Error getting tables: $e');
    }
  }

  @override
  Future<void> updateTableStatus(int tableId, String status) async {
    try {
      await localDataSource.updateTableStatus(tableId, status);
    } catch (e) {
      throw Exception('Error updating table status: $e');
    }
  }

  @override
  Future<void> createTablesForPointOfSale(
      int pointOfSaleId, int numberOfTables) async {
    try {
      await localDataSource.createTablesForPointOfSale(
          pointOfSaleId, numberOfTables);
    } catch (e) {
      throw Exception('Error creating tables for point of sale: $e');
    }
  }
}


