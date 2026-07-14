class ImageUploadResponse {
  final String url;
  final String publicId;

  ImageUploadResponse({
    required this.url,
    required this.publicId,
  });

  factory ImageUploadResponse.fromJson(Map<String, dynamic> json) {
    return ImageUploadResponse(
      url: json['secure_url'] ?? '',
      publicId: json['public_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'publicId': publicId,
    };
  }
}
