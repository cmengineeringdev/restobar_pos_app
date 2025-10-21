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
  Future<List<OrderItemModel>> getOrderItems(int orderId);
  Future<void> updateOrder(OrderModel order);
  Future<void> updateOrderStatus(int orderId, String status);
  Future<void> updateOrderNotes(int orderId, String? notes);
  Future<void> closeOrder(int orderId);
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

      // Buscar órdenes activas (open, preparing, ready, delivered) pero no cerradas ni canceladas
      final List<Map<String, dynamic>> maps = await db.query(
        'orders',
        where: 'table_id = ? AND status NOT IN (?, ?)',
        whereArgs: [tableId, 'closed', 'cancelled'],
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
  Future<void> updateOrderStatus(int orderId, String status) async {
    try {
      final db = await databaseService.database;

      await db.update(
        'orders',
        {
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [orderId],
      );

      print('DEBUG LOCAL ORDER: Status de orden $orderId actualizado a $status');
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
}

