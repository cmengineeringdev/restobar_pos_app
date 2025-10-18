import '../../../core/database/database_service.dart';
import '../../models/point_of_sale_model.dart';

abstract class PointOfSaleLocalDataSource {
  Future<PointOfSaleModel?> getSelectedPointOfSale();
  Future<void> saveSelectedPointOfSale(PointOfSaleModel pointOfSale);
  Future<void> clearSelectedPointOfSale();
}

class PointOfSaleLocalDataSourceImpl implements PointOfSaleLocalDataSource {
  final DatabaseService databaseService;

  PointOfSaleLocalDataSourceImpl({required this.databaseService});

  @override
  Future<PointOfSaleModel?> getSelectedPointOfSale() async {
    final db = await databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'selected_point_of_sale',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return PointOfSaleModel.fromMap(maps.first);
  }

  @override
  Future<void> saveSelectedPointOfSale(PointOfSaleModel pointOfSale) async {
    final db = await databaseService.database;

    // Clear any existing selection
    await db.delete('selected_point_of_sale');

    // Insert new selection with selected_at timestamp
    final map = pointOfSale.toMap();
    map['selected_at'] = DateTime.now().toIso8601String();

    await db.insert('selected_point_of_sale', map);
  }

  @override
  Future<void> clearSelectedPointOfSale() async {
    final db = await databaseService.database;
    await db.delete('selected_point_of_sale');
  }
}
