class Table {
  final int? id;
  final String number;
  final int capacity;
  final String status; // 'available' o 'occupied'
  final int pointOfSaleId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Table({
    this.id,
    required this.number,
    required this.capacity,
    required this.status,
    required this.pointOfSaleId,
    required this.createdAt,
    this.updatedAt,
  });

  Table copyWith({
    int? id,
    String? number,
    int? capacity,
    String? status,
    int? pointOfSaleId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Table(
      id: id ?? this.id,
      number: number ?? this.number,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      pointOfSaleId: pointOfSaleId ?? this.pointOfSaleId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Table{id: $id, number: $number, capacity: $capacity, status: $status, pointOfSaleId: $pointOfSaleId, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}


