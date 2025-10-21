import '../../domain/entities/work_shift.dart';

class WorkShiftModel extends WorkShift {
  WorkShiftModel({
    super.localId,
    super.remoteId,
    required super.openDate,
    super.closeDate,
    required super.companyId,
    required super.pointOfSaleId,
    super.userId,
    super.isActive,
  });

  /// Convert from API JSON to WorkShiftModel
  factory WorkShiftModel.fromJson(Map<String, dynamic> json) {
    return WorkShiftModel(
      remoteId: json['id'] as int?,
      openDate: DateTime.parse(json['openDate'] as String),
      closeDate: json['closeDate'] != null
          ? DateTime.parse(json['closeDate'] as String)
          : null,
      companyId: json['companyId'] as int,
      pointOfSaleId: json['pointOfSaleId'] as int,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Convert from database map to WorkShiftModel
  factory WorkShiftModel.fromMap(Map<String, dynamic> map) {
    return WorkShiftModel(
      localId: map['id'] as int?,
      remoteId: map['remote_id'] as int?,
      openDate: DateTime.parse(map['open_date'] as String),
      closeDate: map['close_date'] != null
          ? DateTime.parse(map['close_date'] as String)
          : null,
      companyId: map['company_id'] as int,
      pointOfSaleId: map['point_of_sale_id'] as int,
      userId: map['user_id'] as String?,
      isActive: (map['is_active'] as int? ?? 1) == 1,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      if (localId != null) 'id': localId,
      'remote_id': remoteId,
      'open_date': openDate.toIso8601String(),
      'close_date': closeDate?.toIso8601String(),
      'company_id': companyId,
      'point_of_sale_id': pointOfSaleId,
      'user_id': userId,
      'is_active': isActive ? 1 : 0,
    };
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'pointOfSaleId': pointOfSaleId,
    };
  }

  /// Convert from entity
  factory WorkShiftModel.fromEntity(WorkShift workShift) {
    return WorkShiftModel(
      localId: workShift.localId,
      remoteId: workShift.remoteId,
      openDate: workShift.openDate,
      closeDate: workShift.closeDate,
      companyId: workShift.companyId,
      pointOfSaleId: workShift.pointOfSaleId,
      userId: workShift.userId,
      isActive: workShift.isActive,
    );
  }

  /// Convert to entity
  WorkShift toEntity() {
    return WorkShift(
      localId: localId,
      remoteId: remoteId,
      openDate: openDate,
      closeDate: closeDate,
      companyId: companyId,
      pointOfSaleId: pointOfSaleId,
      userId: userId,
      isActive: isActive,
    );
  }
}

/// API Response for WorkShift
class WorkShiftResponse {
  final bool success;
  final String message;
  final WorkShiftModel? data;

  WorkShiftResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory WorkShiftResponse.fromJson(Map<String, dynamic> json) {
    WorkShiftModel? workShift;

    if (json['data'] != null) {
      workShift = WorkShiftModel.fromJson(json['data'] as Map<String, dynamic>);
    }

    return WorkShiftResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: workShift,
    );
  }
}

