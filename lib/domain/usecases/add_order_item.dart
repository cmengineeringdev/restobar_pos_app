import '../repositories/order_repository.dart';

class AddOrderItem {
  final OrderRepository repository;

  AddOrderItem(this.repository);

  Future<void> call({
    required int orderId,
    required int productId,
    required String productName,
    required int quantity,
    required double unitPrice,
  }) async {
    return await repository.addOrderItem(
      orderId: orderId,
      productId: productId,
      productName: productName,
      quantity: quantity,
      unitPrice: unitPrice,
    );
  }
}


