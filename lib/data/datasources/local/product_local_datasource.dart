import '../../../core/database/database_service.dart';
import '../../models/product_model.dart';

abstract class ProductLocalDataSource {
  Future<List<ProductModel>> getAllProducts();
  Future<ProductModel?> getProductById(int id);
  Future<List<ProductModel>> searchProductsByName(String name);
  Future<int> insertProduct(ProductModel product);
  Future<int> updateProduct(ProductModel product);
  Future<int> deleteProduct(int id);
  Future<void> insertProducts(List<ProductModel> products);
  Future<void> deleteAllProducts();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final DatabaseService databaseService;

  ProductLocalDataSourceImpl({required this.databaseService});

  @override
  Future<List<ProductModel>> getAllProducts() async {
    final db = await databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) => ProductModel.fromMap(maps[i]));
  }

  @override
  Future<ProductModel?> getProductById(int id) async {
    final db = await databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return ProductModel.fromMap(maps.first);
  }

  @override
  Future<List<ProductModel>> searchProductsByName(String name) async {
    final db = await databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'name LIKE ? AND is_active = ?',
      whereArgs: ['%$name%', 1],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) => ProductModel.fromMap(maps[i]));
  }

  @override
  Future<int> insertProduct(ProductModel product) async {
    final db = await databaseService.database;

    // Check if product with same remote_id exists
    final existing = await db.query(
      'products',
      where: 'remote_id = ?',
      whereArgs: [product.remoteId],
    );

    if (existing.isNotEmpty) {
      // Update existing product
      final productMap = product.toMap();
      productMap['updated_at'] = DateTime.now().toIso8601String();

      return await db.update(
        'products',
        productMap,
        where: 'remote_id = ?',
        whereArgs: [product.remoteId],
      );
    } else {
      // Insert new product
      return await db.insert('products', product.toMap());
    }
  }

  @override
  Future<int> updateProduct(ProductModel product) async {
    final db = await databaseService.database;
    final productMap = product.toMap();
    productMap['updated_at'] = DateTime.now().toIso8601String();

    return await db.update(
      'products',
      productMap,
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  @override
  Future<int> deleteProduct(int id) async {
    final db = await databaseService.database;
    return await db.update(
      'products',
      {
        'is_active': 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> insertProducts(List<ProductModel> products) async {
    final db = await databaseService.database;
    final batch = db.batch();

    for (var product in products) {
      // For batch sync, we use INSERT OR REPLACE based on remote_id
      batch.rawInsert('''
        INSERT INTO products (
          remote_id, name, description, sale_price, is_active,
          product_category_id, tax_rate_id, formula_id, formula_code,
          formula_name, created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(remote_id) DO UPDATE SET
          name = excluded.name,
          description = excluded.description,
          sale_price = excluded.sale_price,
          is_active = excluded.is_active,
          product_category_id = excluded.product_category_id,
          tax_rate_id = excluded.tax_rate_id,
          formula_id = excluded.formula_id,
          formula_code = excluded.formula_code,
          formula_name = excluded.formula_name,
          updated_at = ?
      ''', [
        product.remoteId,
        product.name,
        product.description,
        product.salePrice,
        product.isActive ? 1 : 0,
        product.productCategoryId,
        product.taxRateId,
        product.formulaId,
        product.formulaCode,
        product.formulaName,
        product.createdAt.toIso8601String(),
        product.updatedAt?.toIso8601String(),
        DateTime.now().toIso8601String(), // For the UPDATE part
      ]);
    }

    await batch.commit(noResult: true);
  }

  @override
  Future<void> deleteAllProducts() async {
    final db = await databaseService.database;
    await db.delete('products');
  }
}
