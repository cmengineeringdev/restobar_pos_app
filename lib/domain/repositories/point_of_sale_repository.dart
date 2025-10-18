import '../entities/point_of_sale.dart';

abstract class PointOfSaleRepository {
  Future<List<PointOfSale>> getPointsOfSale();
  Future<PointOfSale?> getSelectedPointOfSale();
  Future<void> selectPointOfSale(PointOfSale pointOfSale);
  Future<void> clearSelectedPointOfSale();
}
