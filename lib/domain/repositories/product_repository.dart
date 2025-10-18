import '../entities/product.dart';

abstract class ProductRepository {
  /// Get all active products from local database
  Future<List<Product>> getAllProducts();

  /// Get product by ID from local database
  Future<Product?> getProductById(int id);

  /// Search products by name in local database
  Future<List<Product>> searchProductsByName(String name);

  /// Insert a new product to local database
  Future<int> insertProduct(Product product);

  /// Update an existing product in local database
  Future<int> updateProduct(Product product);

  /// Delete (deactivate) a product in local database
  Future<int> deleteProduct(int id);

  /// Fetch products from remote API
  Future<List<Product>> fetchProductsFromApi();

  /// Sync products: fetch from API and save to local database
  Future<List<Product>> syncProducts();
}
