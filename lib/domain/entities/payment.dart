class Payment {
  final int? id;
  final int orderId;
  final String paymentMethod; // 'cash', 'credit_card', 'debit_card'
  final double amount;
  final String status; // 'pending', 'completed', 'failed'
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Payment({
    this.id,
    required this.orderId,
    required this.paymentMethod,
    required this.amount,
    required this.status,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  Payment copyWith({
    int? id,
    int? orderId,
    String? paymentMethod,
    double? amount,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Payment(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Payment{id: $id, orderId: $orderId, paymentMethod: $paymentMethod, amount: $amount, status: $status}';
  }
}









