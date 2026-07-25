import 'service_model.dart';
import '../../domain/entities/service_entity.dart';

class CenterServiceDetailsResponseModel {
  final bool success;
  final String message;
  final ServiceModel? service;

  CenterServiceDetailsResponseModel({
    required this.success,
    required this.message,
    this.service,
  });

  factory CenterServiceDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    ServiceModel? s;
    if (json['data'] != null && json['data']['service'] != null) {
      s = ServiceModel.fromJson(json['data']['service']);
    }
    return CenterServiceDetailsResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      service: s,
    );
  }

  ServiceEntity? toEntity() {
    return service?.toEntity();
  }
}
