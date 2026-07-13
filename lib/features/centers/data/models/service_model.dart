import '../../domain/entities/service_entity.dart';

class ServiceModel {
  final String id;
  final String serviceName;
  final String description;
  final double price;
  final String estimatedTime;
  final String warranty;
  final bool isAvailable;

  ServiceModel({
    required this.id,
    required this.serviceName,
    required this.description,
    required this.price,
    required this.estimatedTime,
    required this.warranty,
    required this.isAvailable,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['_id'] ?? '',
      serviceName: json['serviceName'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      estimatedTime: json['estimatedTime'] ?? '',
      warranty: json['warranty'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  ServiceEntity toEntity() {
    return ServiceEntity(
      id: id,
      serviceName: serviceName,
      description: description,
      price: price,
      estimatedTime: estimatedTime,
      warranty: warranty,
      isAvailable: isAvailable,
    );
  }
}

class CenterServicesResponseModel {
  final bool success;
  final String message;
  final List<ServiceModel> services;
  final int total;

  CenterServicesResponseModel({
    required this.success,
    required this.message,
    required this.services,
    required this.total,
  });

  factory CenterServicesResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final servicesList = data['services'] as List<dynamic>? ?? [];

    return CenterServicesResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      services: servicesList.map((e) => ServiceModel.fromJson(e)).toList(),
      total: data['total'] ?? 0,
    );
  }
}
