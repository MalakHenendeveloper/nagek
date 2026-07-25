import 'center_model.dart';

class UpdateCenterProfileResponseModel {
  final bool success;
  final String message;
  final CenterModel? center;

  UpdateCenterProfileResponseModel({
    required this.success,
    required this.message,
    this.center,
  });

  factory UpdateCenterProfileResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final centerJson = data?['center'] as Map<String, dynamic>?;

    return UpdateCenterProfileResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      center: centerJson != null ? CenterModel.fromJson(centerJson) : null,
    );
  }
}
