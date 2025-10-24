import '../repositories/order_repository.dart';
import '../repositories/table_repository.dart';

class CompleteOrder {
  final OrderRepository orderRepository;
  final TableRepository tableRepository;

  CompleteOrder({
    required this.orderRepository,
    required this.tableRepository,
  });

  /// Completa un pedido, lo cierra y libera la mesa
  Future<void> call({
    required int orderId,
    required int tableId,
  }) async {
    try {
      // 1. Cerrar el pedido (status = 'closed')
      await orderRepository.closeOrder(orderId);

      // 2. Actualizar estado de la mesa a 'available'
      await tableRepository.updateTableStatus(tableId, 'available');

      print('DEBUG COMPLETE ORDER: Pedido $orderId completado y mesa $tableId liberada');
    } catch (e) {
      print('DEBUG COMPLETE ORDER: Error al completar pedido: $e');
      throw Exception('Error completing order: $e');
    }
  }
}


