import '../entities/order.dart';
import '../entities/order_item.dart';

abstract class OrderRepository {
  /// Create a new order
  Future<Order> createOrder({
    required int tableId,
    required int workShiftId,
  });

  /// Add item to order
  Future<void> addOrderItem({
    required int orderId,
    required int productId,
    required String productName,
    required int quantity,
    required double unitPrice,
  });

  /// Get order item by product
  Future<OrderItem?> getOrderItemByProduct(int orderId, int productId);

  /// Update order item
  Future<void> updateOrderItem(OrderItem item);

  /// Delete order item
  Future<void> deleteOrderItem(int itemId);

  /// Get order by table
  Future<Order?> getOrderByTable(int tableId);

  /// Get order items
  Future<List<OrderItem>> getOrderItems(int orderId);

  /// Update order totals
  Future<void> updateOrderTotals({
    required int orderId,
    required double subtotal,
    required double tax,
    required double total,
  });

  /// Update order status
  Future<void> updateOrderStatus({
    required int orderId,
    required String status,
  });

  /// Update order notes
  Future<void> updateOrderNotes({
    required int orderId,
    required String? notes,
  });

  /// Close order
  Future<void> closeOrder(int orderId);
}

