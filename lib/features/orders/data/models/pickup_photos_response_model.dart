class PickupPhotosResponseModel {
  final bool success;
  final String message;
  final List<String> photoUrls;

  PickupPhotosResponseModel({
    required this.success,
    required this.message,
    required this.photoUrls,
  });

  factory PickupPhotosResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final atPickup = data['atPickup'] as List? ?? [];

    return PickupPhotosResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      photoUrls: atPickup.map((e) => e.toString()).toList(),
    );
  }
}
