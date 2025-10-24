import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/local/order_local_datasource.dart';
import '../datasources/remote/order_remote_datasource.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';
import '../models/order_request_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderLocalDataSource localDataSource;
  final OrderRemoteDataSource? remoteDataSource;

  OrderRepositoryImpl({
    required this.localDataSource,
    this.remoteDataSource,
  });

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
  Future<Order?> getOrderById(int orderId) async {
    try {
      final orderModel = await localDataSource.getOrderById(orderId);
      return orderModel?.toEntity();
    } catch (e) {
      throw Exception('Error getting order by ID: $e');
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
      final currentOrder = await localDataSource.getOrderById(orderId);
      if (currentOrder == null) {
        throw Exception('Order not found with ID: $orderId');
      }

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
      print('DEBUG REPO: Totales actualizados - Subtotal: $subtotal, Tax: $tax, Total: $total');
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

  @override
  Future<Map<String, dynamic>> getWorkShiftSalesSummary(int workShiftId) async {
    try {
      return await localDataSource.getWorkShiftSalesSummary(workShiftId);
    } catch (e) {
      throw Exception('Error getting work shift sales summary: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getClosedOrdersByWorkShift(int workShiftId) async {
    try {
      return await localDataSource.getClosedOrdersByWorkShift(workShiftId);
    } catch (e) {
      throw Exception('Error getting closed orders by work shift: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getOrderWithDetails(int orderId) async {
    try {
      return await localDataSource.getOrderWithDetails(orderId);
    } catch (e) {
      throw Exception('Error getting order with details: $e');
    }
  }

  @override
  Future<void> sendOrderToRemote({
    required int orderId,
    required int tableNumber,
    required int remoteWorkshiftId,
    required int remoteSalesPointId,
  }) async {
    try {
      if (remoteDataSource == null) {
        throw Exception('Remote datasource not configured');
      }

      // Obtener la orden con sus detalles desde la BD local
      final orderData = await localDataSource.getOrderWithDetails(orderId);
      final order = orderData['order'] as Map<String, dynamic>;
      final items = orderData['items'] as List<Map<String, dynamic>>;

      // Construir los detalles de la orden usando los remote_id de productos
      final orderDetails = <OrderDetailRequestModel>[];

      for (final item in items) {
        final productRemoteId = item['product_remote_id'];

        if (productRemoteId == null) {
          throw Exception(
              'Product remote_id not found for product: ${item['product_name']}');
        }

        orderDetails.add(OrderDetailRequestModel(
          productId: productRemoteId as int,
          productName: item['product_name'] as String,
          quantity: item['quantity'] as int,
          unitPrice: (item['unit_price'] as num).toDouble(),
          subtotal: (item['subtotal'] as num).toDouble(),
        ));
      }

      // Crear el request model
      final orderRequest = OrderRequestModel(
        tableNumber: tableNumber,
        workshiftId: remoteWorkshiftId,
        salesPointId: remoteSalesPointId,
        status: 'pending',
        subtotal: (order['subtotal'] as num).toDouble(),
        tax: (order['tax'] as num).toDouble(),
        total: (order['total'] as num).toDouble(),
        orderDetails: orderDetails,
      );

      // Enviar al API remoto
      await remoteDataSource!.sendOrderToApi(orderRequest);

      print('DEBUG REPO: Orden $orderId enviada exitosamente al servidor remoto');
    } catch (e) {
      throw Exception('Error sending order to remote: $e');
    }
  }
}

