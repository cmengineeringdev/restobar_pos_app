import '../entities/order.dart';
import '../repositories/order_repository.dart';

class CreateOrder {
  final OrderRepository repository;

  CreateOrder(this.repository);

  Future<Order> call({
    required int tableId,
    required int workShiftId,
  }) async {
    return await repository.createOrder(
      tableId: tableId,
      workShiftId: workShiftId,
    );
  }
}


