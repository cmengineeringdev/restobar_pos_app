import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/local/product_local_datasource.dart';
import '../datasources/remote/product_remote_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource localDataSource;
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<Product>> getAllProducts() async {
    final productModels = await localDataSource.getAllProducts();
    return productModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Product?> getProductById(int id) async {
    final productModel = await localDataSource.getProductById(id);
    return productModel?.toEntity();
  }

  @override
  Future<List<Product>> searchProductsByName(String name) async {
    final productModels = await localDataSource.searchProductsByName(name);
    return productModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<int> insertProduct(Product product) async {
    final productModel = ProductModel.fromEntity(product);
    return await localDataSource.insertProduct(productModel);
  }

  @override
  Future<int> updateProduct(Product product) async {
    final productModel = ProductModel.fromEntity(product);
    return await localDataSource.updateProduct(productModel);
  }

  @override
  Future<int> deleteProduct(int id) async {
    return await localDataSource.deleteProduct(id);
  }

  @override
  Future<List<Product>> fetchProductsFromApi({required int pointOfSaleId}) async {
    final productModels = await remoteDataSource.getProductsFromApi(
      pointOfSaleId: pointOfSaleId,
    );
    return productModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Product>> syncProducts({required int pointOfSaleId}) async {
    // Fetch products from API
    final productModels = await remoteDataSource.getProductsFromApi(
      pointOfSaleId: pointOfSaleId,
    );

    // Save/Update to local database (using UPSERT strategy)
    // This will insert new products or update existing ones based on remote_id
    await localDataSource.insertProducts(productModels);

    // Return entities
    return productModels.map((model) => model.toEntity()).toList();
  }
}
