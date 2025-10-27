import '../../domain/entities/order.dart';

class OrderModel {
  final int? id;
  final int tableId;
  final int workShiftId;
  final String status;
  final double subtotal;
  final double tax;
  final double tip;
  final double total;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? closedAt;

  OrderModel({
    this.id,
    required this.tableId,
    required this.workShiftId,
    required this.status,
    required this.subtotal,
    required this.tax,
    this.tip = 0,
    required this.total,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.closedAt,
  });

  /// Convert from Map (Database)
  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] as int?,
      tableId: map['table_id'] as int,
      workShiftId: map['work_shift_id'] as int,
      status: map['status'] as String,
      subtotal: (map['subtotal'] as num).toDouble(),
      tax: (map['tax'] as num).toDouble(),
      tip: map['tip'] != null ? (map['tip'] as num).toDouble() : 0,
      total: (map['total'] as num).toDouble(),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      closedAt: map['closed_at'] != null
          ? DateTime.parse(map['closed_at'] as String)
          : null,
    );
  }

  /// Convert to Map (Database)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'table_id': tableId,
      'work_shift_id': workShiftId,
      'status': status,
      'subtotal': subtotal,
      'tax': tax,
      'tip': tip,
      'total': total,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'closed_at': closedAt?.toIso8601String(),
    };
  }

  /// Convert to Entity
  Order toEntity() {
    return Order(
      id: id,
      tableId: tableId,
      workShiftId: workShiftId,
      status: status,
      subtotal: subtotal,
      tax: tax,
      tip: tip,
      total: total,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      closedAt: closedAt,
    );
  }

  /// Create from Entity
  factory OrderModel.fromEntity(Order order) {
    return OrderModel(
      id: order.id,
      tableId: order.tableId,
      workShiftId: order.workShiftId,
      status: order.status,
      subtotal: order.subtotal,
      tax: order.tax,
      tip: order.tip,
      total: order.total,
      notes: order.notes,
      createdAt: order.createdAt,
      updatedAt: order.updatedAt,
      closedAt: order.closedAt,
    );
  }
}

