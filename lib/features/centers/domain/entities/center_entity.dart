class CoordinatesEntity {
  final double lat;
  final double lng;

  const CoordinatesEntity({required this.lat, required this.lng});
}

class CenterEntity {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String city;
  final String status;
  final String logo;
  final List<String> supportedBrands;
  final List<String> supportedDeviceTypes;
  final double rating;
  final int totalRatings;
  final double? distance;
  final CoordinatesEntity coordinates;
  final double inspectionFee;

  CenterEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.city,
    required this.status,
    required this.logo,
    required this.supportedBrands,
    required this.supportedDeviceTypes,
    required this.rating,
    required this.totalRatings,
    required this.coordinates,
    required this.inspectionFee,
    this.distance,
  });
}

class PaginationEntity {
  final int total;
  final int page;
  final int limit;
  final int pages;

  PaginationEntity({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });
}

class CentersResultEntity {
  final List<CenterEntity> centers;
  final PaginationEntity pagination;

  CentersResultEntity({
    required this.centers,
    required this.pagination,
  });
}
