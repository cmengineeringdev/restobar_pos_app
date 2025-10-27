class Product {
  final int? id; // Local ID (autoincremental)
  final int remoteId; // ID from API
  final String name;
  final String? description;
  final double salePrice;
  final bool isActive;
  final bool isAvailable; // If product is available for sale
  final int? productCategoryId;
  final int? taxRateId;
  final double? taxRate; // Tax rate percentage (e.g., 16.0 for 16%)
  final int? formulaId;
  final String? formulaCode;
  final String? formulaName;
  final DateTime createdAt; // Local creation timestamp
  final DateTime? updatedAt; // Local update timestamp

  Product({
    this.id,
    required this.remoteId,
    required this.name,
    this.description,
    required this.salePrice,
    this.isActive = true,
    this.isAvailable = true,
    this.productCategoryId,
    this.taxRateId,
    this.taxRate,
    this.formulaId,
    this.formulaCode,
    this.formulaName,
    required this.createdAt,
    this.updatedAt,
  });

  Product copyWith({
    int? id,
    int? remoteId,
    String? name,
    String? description,
    double? salePrice,
    bool? isActive,
    bool? isAvailable,
    int? productCategoryId,
    int? taxRateId,
    double? taxRate,
    int? formulaId,
    String? formulaCode,
    String? formulaName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      name: name ?? this.name,
      description: description ?? this.description,
      salePrice: salePrice ?? this.salePrice,
      isActive: isActive ?? this.isActive,
      isAvailable: isAvailable ?? this.isAvailable,
      productCategoryId: productCategoryId ?? this.productCategoryId,
      taxRateId: taxRateId ?? this.taxRateId,
      taxRate: taxRate ?? this.taxRate,
      formulaId: formulaId ?? this.formulaId,
      formulaCode: formulaCode ?? this.formulaCode,
      formulaName: formulaName ?? this.formulaName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Product{id: $id, remoteId: $remoteId, name: $name, salePrice: $salePrice}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Product &&
        other.id == id &&
        other.remoteId == remoteId &&
        other.name == name &&
        other.description == description &&
        other.salePrice == salePrice &&
        other.isActive == isActive &&
        other.isAvailable == isAvailable &&
        other.productCategoryId == productCategoryId &&
        other.taxRateId == taxRateId &&
        other.taxRate == taxRate &&
        other.formulaId == formulaId &&
        other.formulaCode == formulaCode &&
        other.formulaName == formulaName &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        remoteId.hashCode ^
        name.hashCode ^
        description.hashCode ^
        salePrice.hashCode ^
        isActive.hashCode ^
        isAvailable.hashCode ^
        productCategoryId.hashCode ^
        taxRateId.hashCode ^
        taxRate.hashCode ^
        formulaId.hashCode ^
        formulaCode.hashCode ^
        formulaName.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
