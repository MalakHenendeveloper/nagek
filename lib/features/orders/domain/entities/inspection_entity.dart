class InspectionFindingEntity {
  final String issue;
  final String severity;

  InspectionFindingEntity({
    required this.issue,
    required this.severity,
  });
}

class InspectionEntity {
  final String id;
  final String technician;
  final List<InspectionFindingEntity> findings;
  final String notes;
  final List<String> images;
  final String inspectedAt;

  InspectionEntity({
    required this.id,
    required this.technician,
    required this.findings,
    required this.notes,
    required this.images,
    required this.inspectedAt,
  });
}
