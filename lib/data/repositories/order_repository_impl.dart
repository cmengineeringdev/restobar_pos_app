import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/local/order_local_datasource.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderLocalDataSource localDataSource;

  OrderRepositoryImpl({required this.localDataSource});

  @override
  Future<Order> createOrder({
    required int tableId,
    required int workShiftId,
  }) async {
    try {
      final orderModel = OrderModel(
        tableId: tableId,
        workShiftId: workShiftId,
        status: 'open',
        subtotal: 0,
        tax: 0,
        total: 0,
        createdAt: DateTime.now(),
      );

      final id = await localDataSource.createOrder(orderModel);

      return Order(
        id: id,
        tableId: tableId,
        workShiftId: workShiftId,
        status: 'open',
        subtotal: 0,
        tax: 0,
        total: 0,
        createdAt: orderModel.createdAt,
      );
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }

  @override
  Future<void> addOrderItem({
    required int orderId,
    required int productId,
    required String productName,
    required int quantity,
    required double unitPrice,
  }) async {
    try {
      final subtotal = quantity * unitPrice;

      final item = OrderItemModel(
        orderId: orderId,
        productId: productId,
        productName: productName,
        quantity: quantity,
        unitPrice: unitPrice,
        subtotal: subtotal,
        createdAt: DateTime.now(),
      );

      await localDataSource.addOrderItem(item);
    } catch (e) {
      throw Exception('Error adding order item: $e');
    }
  }

  @override
  Future<OrderItem?> getOrderItemByProduct(int orderId, int productId) async {
    try {
      final itemModel = await localDataSource.getOrderItemByProduct(orderId, productId);
      return itemModel?.toEntity();
    } catch (e) {
      throw Exception('Error getting order item by product: $e');
    }
  }

  @override
  Future<void> updateOrderItem(OrderItem item) async {
    try {
      final itemModel = OrderItemModel.fromEntity(item);
      await localDataSource.updateOrderItem(itemModel);
    } catch (e) {
      throw Exception('Error updating order item: $e');
    }
  }

  @override
  Future<void> deleteOrderItem(int itemId) async {
    try {
      await localDataSource.deleteOrderItem(itemId);
    } catch (e) {
      throw Exception('Error deleting order item: $e');
    }
  }

  @override
  Future<Order?> getOrderByTable(int tableId) async {
    try {
      final orderModel = await localDataSource.getOrderByTable(tableId);
      return orderModel?.toEntity();
    } catch (e) {
      throw Exception('Error getting order by table: $e');
    }
  }

  @override
  Future<List<OrderItem>> getOrderItems(int orderId) async {
    try {
      final itemModels = await localDataSource.getOrderItems(orderId);
      return itemModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Error getting order items: $e');
    }
  }

  @override
  Future<void> updateOrderTotals({
    required int orderId,
    required double subtotal,
    required double tax,
    required double total,
  }) async {
    try {
      // Obtener la orden actual para preservar otros campos
      final currentOrder = await localDataSource.getOrderByTable(orderId);
      if (currentOrder == null) return;

      final updatedOrder = OrderModel(
        id: orderId,
        tableId: currentOrder.tableId,
        workShiftId: currentOrder.workShiftId,
        status: currentOrder.status,
        subtotal: subtotal,
        tax: tax,
        total: total,
        notes: currentOrder.notes,
        createdAt: currentOrder.createdAt,
        updatedAt: DateTime.now(),
      );

      await localDataSource.updateOrder(updatedOrder);
    } catch (e) {
      throw Exception('Error updating order totals: $e');
    }
  }

  @override
  Future<void> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    try {
      await localDataSource.updateOrderStatus(orderId, status);
    } catch (e) {
      throw Exception('Error updating order status: $e');
    }
  }

  @override
  Future<void> updateOrderNotes({
    required int orderId,
    required String? notes,
  }) async {
    try {
      await localDataSource.updateOrderNotes(orderId, notes);
    } catch (e) {
      throw Exception('Error updating order notes: $e');
    }
  }

  @override
  Future<void> closeOrder(int orderId) async {
    try {
      await localDataSource.closeOrder(orderId);
    } catch (e) {
      throw Exception('Error closing order: $e');
    }
  }
}

