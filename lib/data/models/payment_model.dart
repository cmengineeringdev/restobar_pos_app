import '../../domain/entities/payment.dart';

class PaymentModel {
  final int? id;
  final int orderId;
  final String paymentMethod;
  final double amount;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PaymentModel({
    this.id,
    required this.orderId,
    required this.paymentMethod,
    required this.amount,
    required this.status,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert from Map (Database)
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

  /// Convert to Map (Database)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'order_id': orderId,
      'payment_method': paymentMethod,
      'amount': amount,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Convert to Entity
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

  /// Create from Entity
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
}

