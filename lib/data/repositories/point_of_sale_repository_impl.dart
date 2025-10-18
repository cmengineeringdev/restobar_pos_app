import '../../domain/entities/point_of_sale.dart';
import '../../domain/repositories/point_of_sale_repository.dart';
import '../datasources/local/point_of_sale_local_datasource.dart';
import '../datasources/remote/point_of_sale_remote_datasource.dart';
import '../models/point_of_sale_model.dart';

class PointOfSaleRepositoryImpl implements PointOfSaleRepository {
  final PointOfSaleRemoteDataSource remoteDataSource;
  final PointOfSaleLocalDataSource localDataSource;

  PointOfSaleRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<PointOfSale>> getPointsOfSale() async {
    final models = await remoteDataSource.getPointsOfSale();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<PointOfSale?> getSelectedPointOfSale() async {
    final model = await localDataSource.getSelectedPointOfSale();
    return model?.toEntity();
  }

  @override
  Future<void> selectPointOfSale(PointOfSale pointOfSale) async {
    final model = PointOfSaleModel.fromEntity(pointOfSale);
    await localDataSource.saveSelectedPointOfSale(model);
  }

  @override
  Future<void> clearSelectedPointOfSale() async {
    await localDataSource.clearSelectedPointOfSale();
  }
}
