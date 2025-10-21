import '../entities/order.dart';
import '../repositories/order_repository.dart';

class GetOrderByTable {
  final OrderRepository repository;

  GetOrderByTable(this.repository);

  Future<Order?> call(int tableId) async {
    return await repository.getOrderByTable(tableId);
  }
}


