import '../entities/payment.dart';

abstract class PaymentRepository {
  /// Create a new payment
  Future<Payment> createPayment({
    required int orderId,
    required String paymentMethod,
    required double amount,
    String? notes,
  });

  /// Get all payments for an order
  Future<List<Payment>> getPaymentsByOrder(int orderId);

  /// Get total paid for an order
  Future<double> getTotalPaidForOrder(int orderId);

  /// Update payment status
  Future<void> updatePaymentStatus({
    required int paymentId,
    required String status,
  });
}

