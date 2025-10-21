class OrderItem {
  final int? id;
  final int orderId;
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final DateTime createdAt;

  OrderItem({
    this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.createdAt,
  });

  OrderItem copyWith({
    int? id,
    int? orderId,
    int? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    double? subtotal,
    DateTime? createdAt,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'OrderItem{id: $id, productName: $productName, quantity: $quantity, subtotal: $subtotal}';
  }
}


