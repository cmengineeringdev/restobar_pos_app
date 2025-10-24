/// Modelo para enviar orden al API remoto
class OrderRequestModel {
  final int tableNumber;
  final int workshiftId;
  final int salesPointId;
  final String status;
  final double subtotal;
  final double tax;
  final double total;
  final List<OrderDetailRequestModel> orderDetails;

  OrderRequestModel({
    required this.tableNumber,
    required this.workshiftId,
    required this.salesPointId,
    required this.status,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.orderDetails,
  });

  Map<String, dynamic> toJson() {
    return {
      'tableNumber': tableNumber,
      'workshiftId': workshiftId,
      'salesPointId': salesPointId,
      'status': status,
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'orderDetails': orderDetails.map((detail) => detail.toJson()).toList(),
    };
  }
}

/// Modelo para detalle de orden en request remoto
class OrderDetailRequestModel {
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  OrderDetailRequestModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'subtotal': subtotal,
    };
  }
}
