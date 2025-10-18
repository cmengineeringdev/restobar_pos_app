import '../entities/point_of_sale.dart';
import '../repositories/point_of_sale_repository.dart';

class GetPointsOfSale {
  final PointOfSaleRepository repository;

  GetPointsOfSale({required this.repository});

  Future<List<PointOfSale>> call() async {
    return await repository.getPointsOfSale();
  }
}
