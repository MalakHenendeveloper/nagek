class BrandModel {
  final String name;
  final String logo;
  final List<DeviceModel> devices;

  BrandModel({
    required this.name,
    required this.logo,
    required this.devices,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      name: json['brand'] as String,
      logo: json['logo'] as String,
      devices: (json['devices'] as List<dynamic>)
          .map((item) => DeviceModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand': name,
      'logo': logo,
      'devices': devices.map((d) => d.toJson()).toList(),
    };
  }
}

class DeviceModel {
  final int id;
  final String brand;
  final String model;
  final String series;
  final int year;

  DeviceModel({
    required this.id,
    required this.brand,
    required this.model,
    required this.series,
    required this.year,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as int,
      brand: json['brand'] as String,
      model: json['model'] as String,
      series: json['series'] as String,
      year: json['year'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'series': series,
      'year': year,
    };
  }
}
