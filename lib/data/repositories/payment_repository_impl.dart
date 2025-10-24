import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/local/payment_local_datasource.dart';
import '../models/payment_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentLocalDataSource localDataSource;

  PaymentRepositoryImpl({required this.localDataSource});

  @override
  Future<Payment> createPayment({
    required int orderId,
    required String paymentMethod,
    required double amount,
    String? notes,
  }) async {
    try {
      final paymentModel = PaymentModel(
        orderId: orderId,
        paymentMethod: paymentMethod,
        amount: amount,
        status: 'completed',
        notes: notes,
        createdAt: DateTime.now(),
      );

      final id = await localDataSource.createPayment(paymentModel);

      return Payment(
        id: id,
        orderId: orderId,
        paymentMethod: paymentMethod,
        amount: amount,
        status: 'completed',
        notes: notes,
        createdAt: paymentModel.createdAt,
      );
    } catch (e) {
      throw Exception('Error creating payment: $e');
    }
  }

  @override
  Future<List<Payment>> getPaymentsByOrder(int orderId) async {
    try {
      final paymentModels = await localDataSource.getPaymentsByOrder(orderId);
      return paymentModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Error getting payments by order: $e');
    }
  }

  @override
  Future<double> getTotalPaidForOrder(int orderId) async {
    try {
      return await localDataSource.getTotalPaidForOrder(orderId);
    } catch (e) {
      throw Exception('Error getting total paid for order: $e');
    }
  }

  @override
  Future<void> updatePaymentStatus({
    required int paymentId,
    required String status,
  }) async {
    try {
      await localDataSource.updatePaymentStatus(paymentId, status);
    } catch (e) {
      throw Exception('Error updating payment status: $e');
    }
  }
}









