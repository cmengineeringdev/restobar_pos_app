import '../../domain/entities/payment.dart';

class PaymentModel extends Payment {
  PaymentModel({
    super.id,
    required super.orderId,
    required super.paymentMethod,
    required super.amount,
    required super.status,
    super.notes,
    required super.createdAt,
    super.updatedAt,
  });

  factory PaymentModel.fromEntity(Payment payment) {
    return PaymentModel(
      id: payment.id,
      orderId: payment.orderId,
      paymentMethod: payment.paymentMethod,
      amount: payment.amount,
      status: payment.status,
      notes: payment.notes,
      createdAt: payment.createdAt,
      updatedAt: payment.updatedAt,
    );
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'] as int?,
      orderId: map['order_id'] as int,
      paymentMethod: map['payment_method'] as String,
      amount: (map['amount'] as num).toDouble(),
      status: map['status'] as String,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'order_id': orderId,
      'payment_method': paymentMethod,
      'amount': amount,
      'status': status,
      if (notes != null) 'notes': notes,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  Payment toEntity() {
    return Payment(
      id: id,
      orderId: orderId,
      paymentMethod: paymentMethod,
      amount: amount,
      status: status,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}




