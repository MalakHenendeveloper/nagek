class PriceOfferEntity {
  final String id;
  final String order;
  final String repairCenter;
  final List<SparePartEntity> spareParts;
  final double laborCost;
  final double inspectionFee;
  final double deliveryFee;
  final double totalCost;
  final int estimatedDays;
  final String notes;
  final String status;
  final String createdAt;

  PriceOfferEntity({
    required this.id,
    required this.order,
    required this.repairCenter,
    required this.spareParts,
    required this.laborCost,
    required this.inspectionFee,
    required this.deliveryFee,
    required this.totalCost,
    required this.estimatedDays,
    required this.notes,
    required this.status,
    required this.createdAt,
  });
}

class SparePartEntity {
  final String name;
  final double cost;

  SparePartEntity({required this.name, required this.cost});
}
