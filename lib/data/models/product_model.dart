import '../../domain/entities/product.dart';

class ProductModel extends Product {
  ProductModel({
    super.id,
    required super.remoteId,
    required super.name,
    super.description,
    required super.salePrice,
    super.isActive = true,
    super.isAvailable = true,
    super.productCategoryId,
    super.taxRateId,
    super.formulaId,
    super.formulaCode,
    super.formulaName,
    required super.createdAt,
    super.updatedAt,
  });

  /// Convert from API JSON to ProductModel
  /// Note: Creates local timestamps, remoteId is taken from API's id
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();

    return ProductModel(
      remoteId: json['id'] as int, // API's ID becomes our remoteId
      name: json['name'] as String,
      description: json['description'] as String?,
      salePrice: (json['salePrice'] as num).toDouble(),
      isActive: json['isActive'] as bool? ?? true,
      isAvailable: json['isAvailable'] as bool? ?? true,
      productCategoryId: json['productCategoryId'] as int?,
      taxRateId: json['taxRateId'] as int?,
      formulaId: json['formulaId'] as int?,
      formulaCode: json['formula']?['code'] as String?,
      formulaName: json['formula']?['name'] as String?,
      createdAt: now, // Local timestamp
      updatedAt: null, // Not updated yet locally
    );
  }

  /// Convert from database map to ProductModel
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int?, // Local ID
      remoteId: map['remote_id'] as int, // Remote API ID
      name: map['name'] as String,
      description: map['description'] as String?,
      salePrice: (map['sale_price'] as num).toDouble(),
      isActive: (map['is_active'] as int? ?? 1) == 1,
      isAvailable: (map['is_available'] as int? ?? 1) == 1,
      productCategoryId: map['product_category_id'] as int?,
      taxRateId: map['tax_rate_id'] as int?,
      formulaId: map['formula_id'] as int?,
      formulaCode: map['formula_code'] as String?,
      formulaName: map['formula_name'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  /// Convert ProductModel to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id, // Only include if exists (for updates)
      'remote_id': remoteId,
      'name': name,
      'description': description,
      'sale_price': salePrice,
      'is_active': isActive ? 1 : 0,
      'is_available': isAvailable ? 1 : 0,
      'product_category_id': productCategoryId,
      'tax_rate_id': taxRateId,
      'formula_id': formulaId,
      'formula_code': formulaCode,
      'formula_name': formulaName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Convert to JSON for API (using remoteId as id)
  Map<String, dynamic> toJson() {
    return {
      'id': remoteId, // Send remote ID to API
      'name': name,
      'description': description,
      'salePrice': salePrice,
      'isActive': isActive,
      'productCategoryId': productCategoryId,
      'taxRateId': taxRateId,
      'formulaId': formulaId,
    };
  }

  /// Convert from domain entity to ProductModel
  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      remoteId: product.remoteId,
      name: product.name,
      description: product.description,
      salePrice: product.salePrice,
      isActive: product.isActive,
      isAvailable: product.isAvailable,
      productCategoryId: product.productCategoryId,
      taxRateId: product.taxRateId,
      formulaId: product.formulaId,
      formulaCode: product.formulaCode,
      formulaName: product.formulaName,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }

  /// Convert to domain entity
  Product toEntity() {
    return Product(
      id: id,
      remoteId: remoteId,
      name: name,
      description: description,
      salePrice: salePrice,
      isActive: isActive,
      isAvailable: isAvailable,
      productCategoryId: productCategoryId,
      taxRateId: taxRateId,
      formulaId: formulaId,
      formulaCode: formulaCode,
      formulaName: formulaName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
