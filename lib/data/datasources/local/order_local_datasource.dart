import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../core/database/database_service.dart';
import '../../models/order_item_model.dart';
import '../../models/order_model.dart';

abstract class OrderLocalDataSource {
  Future<int> createOrder(OrderModel order);
  Future<void> addOrderItem(OrderItemModel item);
  Future<OrderItemModel?> getOrderItemByProduct(int orderId, int productId);
  Future<void> updateOrderItem(OrderItemModel item);
  Future<void> deleteOrderItem(int itemId);
  Future<OrderModel?> getOrderByTable(int tableId);
  Future<OrderModel?> getOrderById(int orderId);
  Future<List<OrderItemModel>> getOrderItems(int orderId);
  Future<void> updateOrder(OrderModel order);
  Future<void> updateOrderStatus(int orderId, String status, {String? cancellationReason});
  Future<void> updateOrderNotes(int orderId, String? notes);
  Future<void> closeOrder(int orderId);
  Future<Map<String, dynamic>> getWorkShiftSalesSummary(int workShiftId);
  Future<List<Map<String, dynamic>>> getClosedOrdersByWorkShift(int workShiftId);
  Future<List<Map<String, dynamic>>> getCancelledOrdersByWorkShift(int workShiftId);
  Future<Map<String, dynamic>> getOrderWithDetails(int orderId);
}

class OrderLocalDataSourceImpl implements OrderLocalDataSource {
  final DatabaseService databaseService;

  OrderLocalDataSourceImpl({required this.databaseService});

  @override
  Future<int> createOrder(OrderModel order) async {
    try {
      final db = await databaseService.database;

      final id = await db.insert(
        'orders',
        order.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('DEBUG LOCAL ORDER: Orden creada con ID: $id');
      return id;
    } catch (e) {
      print('DEBUG LOCAL ORDER: Error al crear orden: $e');
      throw Exception('Error creating order in local DB: $e');
    }
  }

  @override
  Future<void> addOrderItem(OrderItemModel item) async {
    try {
      final db = await databaseService.database;

      await db.insert(
        'order_items',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('DEBUG LOCAL ORDER: Item agregado a orden ${item.orderId}');
    } catch (e) {
      print('DEBUG LOCAL ORDER: Error al agregar item: $e');
      throw Exception('Error adding order item to local DB: $e');
    }
  }

  @override
  Future<OrderItemModel?> getOrderItemByProduct(int orderId, int productId) async {
    try {
      final db = await databaseService.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'order_items',
        where: 'order_id = ? AND product_id = ?',
        whereArgs: [orderId, productId],
        limit: 1,
      );

      if (maps.isEmpty) {
        return null;
      }

      return OrderItemModel.fromMap(maps.first);
    } catch (e) {
      print('DEBUG LOCAL ORDER: Error al buscar item por producto: $e');
      throw Exception('Error getting order item by product from local DB: $e');
    }
  }

  @override
  Future<void> updateOrderItem(OrderItemModel item) async {
    try {
      final db = await databaseService.database;

      await db.update(
        'order_items',
        item.toMap(),
        where: 'id = ?',
        whereArgs: [item.id],
      );

      print('DEBUG LOCAL ORDER: Item ${item.id} actualizado - cantidad: ${item.quantity}');
    } catch (e) {
      print('DEBUG LOCAL ORDER: Error al actualizar item: $e');
      throw Exception('Error updating order item in local DB: $e');
    }
  }

  @override
  Future<void> deleteOrderItem(int itemId) async {
    try {
      final db = await databaseService.database;

      await db.delete(
        'order_items',
        where: 'id = ?',
        whereArgs: [itemId],
      );

      print('DEBUG LOCAL ORDER: Item $itemId eliminado');
    } catch (e) {
      print('DEBUG LOCAL ORDER: Error al eliminar item: $e');
      throw Exception('Error deleting order item from local DB: $e');
    }
  }

  @override
  Future<OrderModel?> getOrderByTable(int tableId) async {
    try {
      final db = await databaseService.database;

      // Buscar órdenes activas (open, preparing, ready, delivered) pero no cerradas
      final List<Map<String, dynamic>> maps = await db.query(
        'orders',
        where: 'table_id = ? AND status != ?',
        whereArgs: [tableId, 'closed'],
        orderBy: 'created_at DESC',
        limit: 1,
      );

      if (maps.isEmpty) {
        print('DEBUG LOCAL ORDER: No se encontró orden activa para mesa $tableId');
        return null;
      }

      final order = OrderModel.fromMap(maps.first);
      print('DEBUG LOCAL ORDER: Orden encontrada para mesa $tableId - status: ${order.status}');
      return order;
    } catch (e) {
      print('DEBUG LOCAL ORDER: Error al obtener orden por mesa: $e');
      throw Exception('Error getting order by table from local DB: $e');
    }
  }

  @override
  Future<OrderModel?> getOrderById(int orderId) async {
    try {
      final db = await databaseService.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'orders',
        where: 'id = ?',
        whereArgs: [orderId],
        limit: 1,
      );

      if (maps.isEmpty) {
        print('DEBUG LOCAL ORDER: No se encontró orden con ID $orderId');
        return null;
      }

      final order = OrderModel.fromMap(maps.first);
      print('DEBUG LOCAL ORDER: Orden encontrada con ID $orderId - Subtotal: ${order.subtotal}, Tax: ${order.tax}, Total: ${order.total}');
      return order;
    } catch (e) {
      print('DEBUG LOCAL ORDER: Error al obtener orden por ID: $e');
      throw Exception('Error getting order by ID from local DB: $e');
    }
  }

  @override
  Future<List<OrderItemModel>> getOrderItems(int orderId) async {
    try {
      final db = await databaseService.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'order_items',
        where: 'order_id = ?',
        whereArgs: [orderId],
        orderBy: 'created_at ASC',
      );

      print('DEBUG LOCAL ORDER: ${maps.length} items encontrados para orden $orderId');
      return List.generate(
        maps.length,
        (i) => OrderItemModel.fromMap(maps[i]),
      );
    } catch (e) {
      print('DEBUG LOCAL ORDER: Error al obtener items de orden: $e');
      throw Exception('Error getting order items from local DB: $e');
    }
  }

  @override
  Future<void> updateOrder(OrderModel order) async {
    try {
      final db = await databaseService.database;

      await db.update(
        'orders',
        order.toMap(),
        where: 'id = ?',
        whereArgs: [order.id],
      );

      print('DEBUG LOCAL ORDER: Orden ${order.id} actualizada');
    } catch (e) {
      print('DEBUG LOCAL ORDER: Error al actualizar orden: $e');
      throw Exception('Error updating order in local DB: $e');
    }
  }

  @override
  Future<void> updateOrderStatus(int orderId, String status, {String? cancellationReason}) async {
    try {
      final db = await databaseService.database;

      final updateData = {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Si se proporciona un motivo de cancelación, agregarlo
      if (cancellationReason != null) {
        updateData['cancellation_reason'] = cancellationReason;
      }

      await db.update(
        'orders',
        updateData,
        where: 'id = ?',
        whereArgs: [orderId],
      );

      print('DEBUG LOCAL ORDER: Status de orden $orderId actualizado a $status${cancellationReason != null ? ' (motivo: $cancellationReason)' : ''}');
    } catch (e) {
      print('DEBUG LOCAL ORDER: Error al actualizar status de orden: $e');
      throw Exception('Error updating order status in local DB: $e');
    }
  }

  @override
  Future<void> updateOrderNotes(int orderId, String? notes) async {
    try {
      final db = await databaseService.database;

      await db.update(
        'orders',
        {
          'notes': notes,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [orderId],
      );

      print('DEBUG LOCAL ORDER: Notas de orden $orderId actualizadas');
    } catch (e) {
      print('DEBUG LOCAL ORDER: Error al actualizar notas de orden: $e');
      throw Exception('Error updating order notes in local DB: $e');
    }
  }

  @override
  Future<void> closeOrder(int orderId) async {
    try {
      final db = await databaseService.database;

      await db.update(
        'orders',
        {
          'status': 'closed',
          'closed_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [orderId],
      );

      print('DEBUG LOCAL ORDER: Orden $orderId cerrada');
    } catch (e) {
      print('DEBUG LOCAL ORDER: Error al cerrar orden: $e');
      throw Exception('Error closing order in local DB: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getWorkShiftSalesSummary(int workShiftId) async {
    try {
      final db = await databaseService.database;

      // Contar órdenes por estado
      final ordersResult = await db.rawQuery('''
        SELECT
          COUNT(CASE WHEN status = 'closed' THEN 1 END) as completed_orders,
          COUNT(CASE WHEN status IN ('preparing', 'ready', 'delivered') THEN 1 END) as active_orders,
          COUNT(CASE WHEN status = 'cancelled' THEN 1 END) as cancelled_orders,
          COUNT(*) as total_orders,
          COALESCE(SUM(CASE WHEN status = 'closed' THEN total ELSE 0 END), 0) as total_sales,
          COALESCE(SUM(CASE WHEN status = 'closed' THEN subtotal ELSE 0 END), 0) as total_subtotal,
          COALESCE(SUM(CASE WHEN status = 'closed' THEN tax ELSE 0 END), 0) as total_tax
        FROM orders
        WHERE work_shift_id = ?
      ''', [workShiftId]);

      // Obtener pagos agrupados por método
      final paymentsResult = await db.rawQuery('''
        SELECT
          payment_method,
          COUNT(*) as count,
          COALESCE(SUM(amount), 0) as total
        FROM payments
        WHERE order_id IN (
          SELECT id FROM orders WHERE work_shift_id = ?
        )
        GROUP BY payment_method
      ''', [workShiftId]);

      print('DEBUG LOCAL ORDER: Resumen de ventas cargado para turno $workShiftId');

      return {
        'orders': ordersResult.first,
        'payments': paymentsResult,
      };
    } catch (e) {
      print('DEBUG LOCAL ORDER: Error al obtener resumen de ventas: $e');
      throw Exception('Error getting work shift sales summary from local DB: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getClosedOrdersByWorkShift(int workShiftId) async {
    try {
      final db = await databaseService.database;

      final orders = await db.rawQuery('''
        SELECT
          id,
          table_id,
          subtotal,
          tax,
          total,
          status,
          notes,
          created_at,
          closed_at
        FROM orders
        WHERE work_shift_id = ? AND status = 'closed'
        ORDER BY closed_at DESC
      ''', [workShiftId]);

      print('DEBUG LOCAL ORDER: ${orders.length} órdenes cerradas encontradas para turno $workShiftId');
      return orders;
    } catch (e) {
      print('DEBUG LOCAL ORDER: Error al obtener órdenes cerradas: $e');
      throw Exception('Error getting closed orders from local DB: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCancelledOrdersByWorkShift(int workShiftId) async {
    try {
      final db = await databaseService.database;

      final orders = await db.rawQuery('''
        SELECT
          id,
          table_id,
          subtotal,
          tax,
          total,
          status,
          notes,
          cancellation_reason,
          created_at,
          closed_at
        FROM orders
        WHERE work_shift_id = ? AND status = 'cancelled'
        ORDER BY closed_at DESC
      ''', [workShiftId]);

      print('DEBUG LOCAL ORDER: ${orders.length} órdenes canceladas encontradas para turno $workShiftId');
      return orders;
    } catch (e) {
      print('DEBUG LOCAL ORDER: Error al obtener órdenes canceladas: $e');
      throw Exception('Error getting cancelled orders from local DB: $e');
    }
  }

  Future<Map<String, dynamic>> getOrderWithDetails(int orderId) async {
    try {
      final db = await databaseService.database;

      // Obtener la orden
      final orderResult = await db.query(
        'orders',
        where: 'id = ?',
        whereArgs: [orderId],
      );

      if (orderResult.isEmpty) {
        throw Exception('Order not found with ID: $orderId');
      }

      // Obtener los items con el remote_id del producto
      final itemsResult = await db.rawQuery('''
        SELECT
          oi.*,
          p.remote_id as product_remote_id
        FROM order_items oi
        LEFT JOIN products p ON oi.product_id = p.id
        WHERE oi.order_id = ?
        ORDER BY oi.created_at ASC
      ''', [orderId]);

      // Obtener los pagos
      final paymentsResult = await db.query(
        'payments',
        where: 'order_id = ?',
        whereArgs: [orderId],
        orderBy: 'created_at ASC',
      );

      print('DEBUG LOCAL ORDER: Orden $orderId con ${itemsResult.length} items y ${paymentsResult.length} pagos');

      return {
        'order': orderResult.first,
        'items': itemsResult,
        'payments': paymentsResult,
      };
    } catch (e) {
      print('DEBUG LOCAL ORDER: Error al obtener detalles de orden: $e');
      throw Exception('Error getting order details from local DB: $e');
    }
  }
}

