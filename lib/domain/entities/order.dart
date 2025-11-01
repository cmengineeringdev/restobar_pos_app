class Order {
  final int? id;
  final int tableId;
  final int workShiftId;
  final String status; // 'open', 'closed', 'cancelled'
  final double subtotal;
  final double tax;
  final double tip; // Propina
  final double total;
  final String? notes; // Notas u observaciones del pedido
  final String? cancellationReason; // Motivo de cancelación
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? closedAt;

  Order({
    this.id,
    required this.tableId,
    required this.workShiftId,
    required this.status,
    required this.subtotal,
    required this.tax,
    this.tip = 0,
    required this.total,
    this.notes,
    this.cancellationReason,
    required this.createdAt,
    this.updatedAt,
    this.closedAt,
  });

  Order copyWith({
    int? id,
    int? tableId,
    int? workShiftId,
    String? status,
    double? subtotal,
    double? tax,
    double? tip,
    double? total,
    String? notes,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? closedAt,
  }) {
    return Order(
      id: id ?? this.id,
      tableId: tableId ?? this.tableId,
      workShiftId: workShiftId ?? this.workShiftId,
      status: status ?? this.status,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      tip: tip ?? this.tip,
      total: total ?? this.total,
      notes: notes ?? this.notes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      closedAt: closedAt ?? this.closedAt,
    );
  }

  @override
  String toString() {
    return 'Order{id: $id, tableId: $tableId, workShiftId: $workShiftId, status: $status, total: $total}';
  }
}

