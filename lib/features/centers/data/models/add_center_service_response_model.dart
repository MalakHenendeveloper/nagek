import 'service_model.dart';
import '../../domain/entities/service_entity.dart';

class AddCenterServiceResponseModel {
  final bool success;
  final String message;
  final ServiceModel? service;

  AddCenterServiceResponseModel({
    required this.success,
    required this.message,
    this.service,
  });

  factory AddCenterServiceResponseModel.fromJson(Map<String, dynamic> json) {
    ServiceModel? s;
    if (json['data'] != null && json['data']['service'] != null) {
      s = ServiceModel.fromJson(json['data']['service']);
    }
    return AddCenterServiceResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      service: s,
    );
  }

  ServiceEntity? toEntity() {
    return service?.toEntity();
  }
}
