class DelegateApplicationEntity {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String nationalIdFrontUrl;
  final String nationalIdBackUrl;
  final String drivingLicenseUrl;
  final String motorcycleLicenseUrl;
  final String status;
  final String? rejectReason;
  final String createdAt;
  final String updatedAt;

  DelegateApplicationEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.nationalIdFrontUrl,
    required this.nationalIdBackUrl,
    required this.drivingLicenseUrl,
    required this.motorcycleLicenseUrl,
    required this.status,
    this.rejectReason,
    required this.createdAt,
    required this.updatedAt,
  });
}
