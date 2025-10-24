import '../repositories/payment_repository.dart';

class GetTotalPaidForOrder {
  final PaymentRepository repository;

  GetTotalPaidForOrder(this.repository);

  Future<double> call(int orderId) async {
    return await repository.getTotalPaidForOrder(orderId);
  }
}




