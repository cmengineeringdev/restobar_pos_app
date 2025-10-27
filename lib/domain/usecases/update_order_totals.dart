import '../repositories/order_repository.dart';

class UpdateOrderTotals {
  final OrderRepository repository;

  UpdateOrderTotals(this.repository);

  Future<void> call({
    required int orderId,
    required double subtotal,
    required double tax,
    double? tip,
    required double total,
  }) async {
    return await repository.updateOrderTotals(
      orderId: orderId,
      subtotal: subtotal,
      tax: tax,
      tip: tip,
      total: total,
    );
  }
}


