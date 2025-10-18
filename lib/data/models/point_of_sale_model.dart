import '../../domain/entities/point_of_sale.dart';

class PointOfSaleModel extends PointOfSale {
  PointOfSaleModel({
    required super.id,
    required super.name,
    required super.address,
    required super.numberOfTables,
    super.managerId,
    super.managerName,
    super.isActive,
    required super.createdAt,
  });

  /// Convert from API JSON to PointOfSaleModel
  factory PointOfSaleModel.fromJson(Map<String, dynamic> json) {
    return PointOfSaleModel(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      numberOfTables: json['numberOfTables'] as int,
      managerId: json['managerId'] as int?,
      managerName: json['managerName'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convert from database map to PointOfSaleModel
  factory PointOfSaleModel.fromMap(Map<String, dynamic> map) {
    return PointOfSaleModel(
      id: map['id'] as int,
      name: map['name'] as String,
      address: map['address'] as String,
      numberOfTables: map['number_of_tables'] as int,
      managerId: map['manager_id'] as int?,
      managerName: map['manager_name'] as String?,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'number_of_tables': numberOfTables,
      'manager_id': managerId,
      'manager_name': managerName,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'numberOfTables': numberOfTables,
      'managerId': managerId,
      'managerName': managerName,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Convert from entity
  factory PointOfSaleModel.fromEntity(PointOfSale pos) {
    return PointOfSaleModel(
      id: pos.id,
      name: pos.name,
      address: pos.address,
      numberOfTables: pos.numberOfTables,
      managerId: pos.managerId,
      managerName: pos.managerName,
      isActive: pos.isActive,
      createdAt: pos.createdAt,
    );
  }

  /// Convert to entity
  PointOfSale toEntity() {
    return PointOfSale(
      id: id,
      name: name,
      address: address,
      numberOfTables: numberOfTables,
      managerId: managerId,
      managerName: managerName,
      isActive: isActive,
      createdAt: createdAt,
    );
  }
}

/// API Response for Point of Sales
class PointOfSalesResponse {
  final bool success;
  final String message;
  final List<PointOfSaleModel>? data;

  PointOfSalesResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory PointOfSalesResponse.fromJson(Map<String, dynamic> json) {
    List<PointOfSaleModel>? pointsOfSale;

    if (json['data'] != null) {
      final dataList = json['data'] as List;
      pointsOfSale = dataList
          .map(
              (item) => PointOfSaleModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return PointOfSalesResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: pointsOfSale,
    );
  }
}
