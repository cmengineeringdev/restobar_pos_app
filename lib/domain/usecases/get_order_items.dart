import '../entities/order_item.dart';
import '../repositories/order_repository.dart';

class GetOrderItems {
  final OrderRepository repository;

  GetOrderItems(this.repository);

  Future<List<OrderItem>> call(int orderId) async {
    return await repository.getOrderItems(orderId);
  }
}


