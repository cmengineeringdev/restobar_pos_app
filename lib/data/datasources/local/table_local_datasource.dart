import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../core/database/database_service.dart';
import '../../models/table_model.dart';

abstract class TableLocalDataSource {
  Future<List<TableModel>> getAllTables(int pointOfSaleId);
  Future<int> insertTable(TableModel table);
  Future<void> updateTableStatus(int tableId, String status);
  Future<void> deleteAllTablesForPointOfSale(int pointOfSaleId);
  Future<void> createTablesForPointOfSale(int pointOfSaleId, int numberOfTables);
}

class TableLocalDataSourceImpl implements TableLocalDataSource {
  final DatabaseService databaseService;

  TableLocalDataSourceImpl({required this.databaseService});

  @override
  Future<List<TableModel>> getAllTables(int pointOfSaleId) async {
    try {
      final db = await databaseService.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'tables',
        where: 'point_of_sale_id = ?',
        whereArgs: [pointOfSaleId],
        orderBy: 'number ASC',
      );

      return List.generate(
        maps.length,
        (i) => TableModel.fromMap(maps[i]),
      );
    } catch (e) {
      throw Exception('Error getting tables from local DB: $e');
    }
  }

  @override
  Future<int> insertTable(TableModel table) async {
    try {
      final db = await databaseService.database;

      final id = await db.insert(
        'tables',
        table.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return id;
    } catch (e) {
      throw Exception('Error inserting table to local DB: $e');
    }
  }

  @override
  Future<void> updateTableStatus(int tableId, String status) async {
    try {
      final db = await databaseService.database;

      await db.update(
        'tables',
        {
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [tableId],
      );
    } catch (e) {
      throw Exception('Error updating table status in local DB: $e');
    }
  }

  @override
  Future<void> deleteAllTablesForPointOfSale(int pointOfSaleId) async {
    try {
      final db = await databaseService.database;

      await db.delete(
        'tables',
        where: 'point_of_sale_id = ?',
        whereArgs: [pointOfSaleId],
      );
    } catch (e) {
      throw Exception('Error deleting tables from local DB: $e');
    }
  }

  @override
  Future<void> createTablesForPointOfSale(
      int pointOfSaleId, int numberOfTables) async {
    try {
      // Primero eliminar las mesas existentes de ese punto de venta
      await deleteAllTablesForPointOfSale(pointOfSaleId);

      // Crear las nuevas mesas
      final now = DateTime.now();
      for (int i = 1; i <= numberOfTables; i++) {
        final table = TableModel(
          number: i.toString().padLeft(2, '0'), // 01, 02, 03, etc.
          capacity: 4, // Capacidad por defecto
          status: 'available',
          pointOfSaleId: pointOfSaleId,
          createdAt: now,
        );

        await insertTable(table);
      }

      print(
          'DEBUG: Created $numberOfTables tables for point of sale $pointOfSaleId');
    } catch (e) {
      throw Exception('Error creating tables for point of sale: $e');
    }
  }
}


