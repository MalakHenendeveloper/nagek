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
    final data = json['data'];
    List? photos;

    if (data is Map<String, dynamic>) {
      // Try data.atPickup
      photos = data['atPickup'] as List?;

      // Try data.delegatePhotos.atPickup
      if (photos == null) {
        final delegatePhotos = data['delegatePhotos'] as Map<String, dynamic>?;
        if (delegatePhotos != null) {
          photos = delegatePhotos['atPickup'] as List?;
        }
      }

      // Try data.photos
      photos ??= data['photos'] as List?;

      // Try data.order.delegatePhotos.atPickup
      if (photos == null) {
        final order = data['order'] as Map<String, dynamic>?;
        if (order != null) {
          final delegatePhotos = order['delegatePhotos'] as Map<String, dynamic>?;
          if (delegatePhotos != null) {
            photos = delegatePhotos['atPickup'] as List?;
          }
        }
      }
    }

    return PickupPhotosResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      photoUrls: (photos ?? []).map((e) => e.toString()).toList(),
    );
  }
}
