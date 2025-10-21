class WorkShift {
  final int? localId; // ID local (autoincremental en SQLite)
  final int? remoteId; // ID del servidor remoto
  final DateTime openDate;
  final DateTime? closeDate;
  final int companyId;
  final int pointOfSaleId;
  final String? userId; // Usuario que abrió el turno
  final bool isActive;

  WorkShift({
    this.localId,
    this.remoteId,
    required this.openDate,
    this.closeDate,
    required this.companyId,
    required this.pointOfSaleId,
    this.userId,
    this.isActive = true,
  });

  bool get isClosed => closeDate != null;

  WorkShift copyWith({
    int? localId,
    int? remoteId,
    DateTime? openDate,
    DateTime? closeDate,
    int? companyId,
    int? pointOfSaleId,
    String? userId,
    bool? isActive,
  }) {
    return WorkShift(
      localId: localId ?? this.localId,
      remoteId: remoteId ?? this.remoteId,
      openDate: openDate ?? this.openDate,
      closeDate: closeDate ?? this.closeDate,
      companyId: companyId ?? this.companyId,
      pointOfSaleId: pointOfSaleId ?? this.pointOfSaleId,
      userId: userId ?? this.userId,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'WorkShift{localId: $localId, remoteId: $remoteId, openDate: $openDate, closeDate: $closeDate, companyId: $companyId, pointOfSaleId: $pointOfSaleId, userId: $userId, isActive: $isActive}';
  }
}

