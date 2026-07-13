class ServiceEntity {
  final String id;
  final String serviceName;
  final String description;
  final double price;
  final String estimatedTime;
  final String warranty;
  final bool isAvailable;

  ServiceEntity({
    required this.id,
    required this.serviceName,
    required this.description,
    required this.price,
    required this.estimatedTime,
    required this.warranty,
    required this.isAvailable,
  });
}
