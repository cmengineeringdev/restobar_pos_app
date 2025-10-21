import '../entities/payment.dart';
import '../repositories/payment_repository.dart';

class CreatePayment {
  final PaymentRepository repository;

  CreatePayment(this.repository);

  Future<Payment> call({
    required int orderId,
    required String paymentMethod,
    required double amount,
    String? notes,
  }) async {
    return await repository.createPayment(
      orderId: orderId,
      paymentMethod: paymentMethod,
      amount: amount,
      notes: notes,
    );
  }
}

