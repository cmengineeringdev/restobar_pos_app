import '../entities/payment.dart';
import '../repositories/payment_repository.dart';

class GetPaymentsByOrder {
  final PaymentRepository repository;

  GetPaymentsByOrder(this.repository);

  Future<List<Payment>> call(int orderId) async {
    return await repository.getPaymentsByOrder(orderId);
  }
}


