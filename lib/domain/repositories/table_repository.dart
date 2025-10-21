import '../entities/table.dart';

abstract class TableRepository {
  /// Get all tables for a point of sale
  Future<List<Table>> getAllTables(int pointOfSaleId);

  /// Update table status
  Future<void> updateTableStatus(int tableId, String status);

  /// Create tables for a point of sale
  Future<void> createTablesForPointOfSale(int pointOfSaleId, int numberOfTables);
}


