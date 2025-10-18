import '../entities/point_of_sale.dart';
import '../repositories/point_of_sale_repository.dart';

class SelectPointOfSale {
  final PointOfSaleRepository repository;

  SelectPointOfSale({required this.repository});

  Future<void> call(PointOfSale pointOfSale) async {
    await repository.selectPointOfSale(pointOfSale);
  }
}
