import '../../domain/entities/inspection_entity.dart';

class InspectionResponseModel {
  final bool success;
  final String message;
  final InspectionModel? inspection;

  InspectionResponseModel({
    required this.success,
    required this.message,
    this.inspection,
  });

  factory InspectionResponseModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    final data = map['data'] as Map? ?? {};
    final inspectionJson = data['inspection'] as Map?;

    return InspectionResponseModel(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      inspection: inspectionJson != null
          ? InspectionModel.fromJson(inspectionJson)
          : null,
    );
  }
}

class InspectionFindingModel {
  final String issue;
  final String severity;

  InspectionFindingModel({
    required this.issue,
    required this.severity,
  });

  factory InspectionFindingModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    return InspectionFindingModel(
      issue: map['issue'] ?? '',
      severity: map['severity'] ?? '',
    );
  }

  InspectionFindingEntity toEntity() {
    return InspectionFindingEntity(
      issue: issue,
      severity: severity,
    );
  }
}

class InspectionModel {
  final String id;
  final String technician;
  final List<InspectionFindingModel> findings;
  final String notes;
  final List<String> images;
  final String inspectedAt;

  InspectionModel({
    required this.id,
    required this.technician,
    required this.findings,
    required this.notes,
    required this.images,
    required this.inspectedAt,
  });

  factory InspectionModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    final findingsList = map['findings'] as List<dynamic>? ?? [];
    return InspectionModel(
      id: map['_id'] ?? '',
      technician: map['technician'] ?? '',
      findings:
          findingsList.map((e) => InspectionFindingModel.fromJson(e as Map?)).toList(),
      notes: map['notes'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      inspectedAt: map['inspectedAt'] ?? '',
    );
  }

  InspectionEntity toEntity() {
    return InspectionEntity(
      id: id,
      technician: technician,
      findings: findings.map((m) => m.toEntity()).toList(),
      notes: notes,
      images: images,
      inspectedAt: inspectedAt,
    );
  }
}
