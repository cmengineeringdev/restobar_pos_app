import '../repositories/order_repository.dart';
import '../repositories/table_repository.dart';

class CancelOrder {
  final OrderRepository orderRepository;
  final TableRepository tableRepository;

  CancelOrder({
    required this.orderRepository,
    required this.tableRepository,
  });

  /// Cancela un pedido y libera la mesa
  Future<void> call({
    required int orderId,
    required int tableId,
  }) async {
    try {
      // 1. Actualizar estado del pedido a 'cancelled'
      await orderRepository.updateOrderStatus(
        orderId: orderId,
        status: 'cancelled',
      );

      // 2. Actualizar estado de la mesa a 'available'
      await tableRepository.updateTableStatus(tableId, 'available');

      print('DEBUG CANCEL ORDER: Pedido $orderId cancelado y mesa $tableId liberada');
    } catch (e) {
      print('DEBUG CANCEL ORDER: Error al cancelar pedido: $e');
      throw Exception('Error cancelling order: $e');
    }
  }
}

