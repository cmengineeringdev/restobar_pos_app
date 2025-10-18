import '../entities/point_of_sale.dart';
import '../repositories/point_of_sale_repository.dart';

class GetSelectedPointOfSale {
  final PointOfSaleRepository repository;

  GetSelectedPointOfSale({required this.repository});

  Future<PointOfSale?> call() async {
    return await repository.getSelectedPointOfSale();
  }
}
