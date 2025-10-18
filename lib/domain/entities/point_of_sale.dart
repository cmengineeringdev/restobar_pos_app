class PointOfSale {
  final int id;
  final String name;
  final String address;
  final int numberOfTables;
  final int? managerId;
  final String? managerName;
  final bool isActive;
  final DateTime createdAt;

  PointOfSale({
    required this.id,
    required this.name,
    required this.address,
    required this.numberOfTables,
    this.managerId,
    this.managerName,
    this.isActive = true,
    required this.createdAt,
  });

  PointOfSale copyWith({
    int? id,
    String? name,
    String? address,
    int? numberOfTables,
    int? managerId,
    String? managerName,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return PointOfSale(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      numberOfTables: numberOfTables ?? this.numberOfTables,
      managerId: managerId ?? this.managerId,
      managerName: managerName ?? this.managerName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'PointOfSale{id: $id, name: $name, address: $address}';
  }
}
