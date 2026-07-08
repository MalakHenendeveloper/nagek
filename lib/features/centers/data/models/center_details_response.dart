import 'center_model.dart';

class CenterDetailsResponseModel {
  final bool success;
  final String message;
  final CenterModel center;

  CenterDetailsResponseModel({
    required this.success,
    required this.message,
    required this.center,
  });

  factory CenterDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final centerJson = data['center'] as Map<String, dynamic>? ?? {};
    
    return CenterDetailsResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      center: CenterModel.fromJson(centerJson),
    );
  }
}
