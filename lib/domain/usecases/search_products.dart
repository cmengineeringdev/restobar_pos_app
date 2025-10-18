import '../entities/product.dart';
import '../repositories/product_repository.dart';

class SearchProducts {
  final ProductRepository repository;

  SearchProducts({required this.repository});

  Future<List<Product>> call(String searchTerm) async {
    if (searchTerm.isEmpty) {
      return await repository.getAllProducts();
    }
    return await repository.searchProductsByName(searchTerm);
  }
}

