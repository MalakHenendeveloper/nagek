import '../../domain/entities/center_entity.dart';

class CoordinatesModel {
  final double lat;
  final double lng;

  CoordinatesModel({required this.lat, required this.lng});

  factory CoordinatesModel.fromJson(Map<String, dynamic> json) {
    return CoordinatesModel(
      lat: (json['lat'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? 0.0).toDouble(),
    );
  }

  CoordinatesEntity toEntity() {
    return CoordinatesEntity(lat: lat, lng: lng);
  }
}

class CenterModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String city;
  final String status;
  final List<String> supportedBrands;
  final List<String> supportedDeviceTypes;
  final double rating;
  final int totalRatings;
  final CoordinatesModel coordinates;
  final double inspectionFee;

  CenterModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.city,
    required this.status,
    required this.supportedBrands,
    required this.supportedDeviceTypes,
    required this.rating,
    required this.totalRatings,
    required this.coordinates,
    required this.inspectionFee,
  });

  factory CenterModel.fromJson(Map<String, dynamic> json) {
    return CenterModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      status: json['status'] ?? '',
      supportedBrands: List<String>.from(json['supportedBrands'] ?? []),
      supportedDeviceTypes: List<String>.from(json['supportedDeviceTypes'] ?? []),
      rating: (json['rating'] ?? 0).toDouble(),
      totalRatings: json['totalRatings'] ?? 0,
      coordinates: CoordinatesModel.fromJson(json['coordinates'] ?? {}),
      inspectionFee: (json['inspectionFee'] ?? 0.0).toDouble(),
    );
  }

  CenterEntity toEntity() {
    return CenterEntity(
      id: id,
      name: name,
      phone: phone,
      email: email,
      address: address,
      city: city,
      status: status,
      supportedBrands: supportedBrands,
      supportedDeviceTypes: supportedDeviceTypes,
      rating: rating,
      totalRatings: totalRatings,
      coordinates: coordinates.toEntity(),
      inspectionFee: inspectionFee,
    );
  }
}

class PaginationModel {
  final int total;
  final int page;
  final int limit;
  final int pages;

  PaginationModel({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      pages: json['pages'] ?? 1,
    );
  }

  PaginationEntity toEntity() {
    return PaginationEntity(
      total: total,
      page: page,
      limit: limit,
      pages: pages,
    );
  }
}

class CentersResponseModel {
  final bool success;
  final String message;
  final List<CenterModel> centers;
  final PaginationModel pagination;

  CentersResponseModel({
    required this.success,
    required this.message,
    required this.centers,
    required this.pagination,
  });

  factory CentersResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final centersList = data['centers'] as List<dynamic>? ?? [];
    
    return CentersResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      centers: centersList.map((e) => CenterModel.fromJson(e)).toList(),
      pagination: PaginationModel.fromJson(json['pagination'] ?? {}),
    );
  }
}
