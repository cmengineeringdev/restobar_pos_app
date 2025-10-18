import '../repositories/point_of_sale_repository.dart';

class ClearPointOfSale {
  final PointOfSaleRepository repository;

  ClearPointOfSale({required this.repository});

  Future<void> call() async {
    await repository.clearSelectedPointOfSale();
  }
}
