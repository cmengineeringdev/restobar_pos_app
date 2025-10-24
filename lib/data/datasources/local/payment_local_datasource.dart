import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../core/database/database_service.dart';
import '../../models/payment_model.dart';

abstract class PaymentLocalDataSource {
  Future<int> createPayment(PaymentModel payment);
  Future<List<PaymentModel>> getPaymentsByOrder(int orderId);
  Future<double> getTotalPaidForOrder(int orderId);
  Future<void> updatePaymentStatus(int paymentId, String status);
}

class PaymentLocalDataSourceImpl implements PaymentLocalDataSource {
  final DatabaseService databaseService;

  PaymentLocalDataSourceImpl({required this.databaseService});

  @override
  Future<int> createPayment(PaymentModel payment) async {
    try {
      final db = await databaseService.database;

      final id = await db.insert(
        'payments',
        payment.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('DEBUG LOCAL PAYMENT: Pago creado con ID: $id');
      return id;
    } catch (e) {
      print('DEBUG LOCAL PAYMENT: Error al crear pago: $e');
      throw Exception('Error creating payment in local DB: $e');
    }
  }

  @override
  Future<List<PaymentModel>> getPaymentsByOrder(int orderId) async {
    try {
      final db = await databaseService.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'payments',
        where: 'order_id = ?',
        whereArgs: [orderId],
        orderBy: 'created_at ASC',
      );

      print('DEBUG LOCAL PAYMENT: ${maps.length} pagos encontrados para orden $orderId');
      return List.generate(
        maps.length,
        (i) => PaymentModel.fromMap(maps[i]),
      );
    } catch (e) {
      print('DEBUG LOCAL PAYMENT: Error al obtener pagos de orden: $e');
      throw Exception('Error getting payments by order from local DB: $e');
    }
  }

  @override
  Future<double> getTotalPaidForOrder(int orderId) async {
    try {
      final db = await databaseService.database;

      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT SUM(amount) as total FROM payments WHERE order_id = ? AND status = ?',
        [orderId, 'completed'],
      );

      final total = result.first['total'];
      final totalPaid = total != null ? (total as num).toDouble() : 0.0;
      
      print('DEBUG LOCAL PAYMENT: Total pagado para orden $orderId: $totalPaid');
      return totalPaid;
    } catch (e) {
      print('DEBUG LOCAL PAYMENT: Error al calcular total pagado: $e');
      throw Exception('Error getting total paid for order from local DB: $e');
    }
  }

  @override
  Future<void> updatePaymentStatus(int paymentId, String status) async {
    try {
      final db = await databaseService.database;

      await db.update(
        'payments',
        {
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [paymentId],
      );

      print('DEBUG LOCAL PAYMENT: Status de pago $paymentId actualizado a $status');
    } catch (e) {
      print('DEBUG LOCAL PAYMENT: Error al actualizar status de pago: $e');
      throw Exception('Error updating payment status in local DB: $e');
    }
  }
}


