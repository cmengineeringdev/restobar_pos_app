import '../../domain/entities/table.dart';

class TableModel {
  final int? id;
  final String number;
  final int capacity;
  final String status;
  final int pointOfSaleId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TableModel({
    this.id,
    required this.number,
    required this.capacity,
    required this.status,
    required this.pointOfSaleId,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert from Map (Database)
  factory TableModel.fromMap(Map<String, dynamic> map) {
    return TableModel(
      id: map['id'] as int?,
      number: map['number'] as String,
      capacity: map['capacity'] as int,
      status: map['status'] as String,
      pointOfSaleId: map['point_of_sale_id'] as int,
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
      'number': number,
      'capacity': capacity,
      'status': status,
      'point_of_sale_id': pointOfSaleId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Convert to Entity
  Table toEntity() {
    return Table(
      id: id,
      number: number,
      capacity: capacity,
      status: status,
      pointOfSaleId: pointOfSaleId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from Entity
  factory TableModel.fromEntity(Table table) {
    return TableModel(
      id: table.id,
      number: table.number,
      capacity: table.capacity,
      status: table.status,
      pointOfSaleId: table.pointOfSaleId,
      createdAt: table.createdAt,
      updatedAt: table.updatedAt,
    );
  }
}


