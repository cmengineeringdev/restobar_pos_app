import '../entities/product.dart';
import '../repositories/product_repository.dart';

class SyncProducts {
  final ProductRepository repository;

  SyncProducts({required this.repository});

  Future<List<Product>> call() async {
    return await repository.syncProducts();
  }
}
