import '../../domain/entities/order_item.dart';

class OrderItemModel {
  final int? id;
  final int orderId;
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final DateTime createdAt;

  OrderItemModel({
    this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.createdAt,
  });

  /// Convert from Map (Database)
  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      id: map['id'] as int?,
      orderId: map['order_id'] as int,
      productId: map['product_id'] as int,
      productName: map['product_name'] as String,
      quantity: map['quantity'] as int,
      unitPrice: (map['unit_price'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convert to Map (Database)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convert to Entity
  OrderItem toEntity() {
    return OrderItem(
      id: id,
      orderId: orderId,
      productId: productId,
      productName: productName,
      quantity: quantity,
      unitPrice: unitPrice,
      subtotal: subtotal,
      createdAt: createdAt,
    );
  }

  /// Create from Entity
  factory OrderItemModel.fromEntity(OrderItem item) {
    return OrderItemModel(
      id: item.id,
      orderId: item.orderId,
      productId: item.productId,
      productName: item.productName,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
      subtotal: item.subtotal,
      createdAt: item.createdAt,
    );
  }
}


