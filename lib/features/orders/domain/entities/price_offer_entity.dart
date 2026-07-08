class SparePartEntity {
  final String id;
  final String name;
  final double cost;

  SparePartEntity({
    required this.id,
    required this.name,
    required this.cost,
  });
}

class PriceOfferEntity {
  final String id;
  final String orderId;
  final String orderStatus;
  final String orderNumber;
  final String centerId;
  final String centerName;
  final String centerPhone;
  final String centerAddress;
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
    required this.orderId,
    required this.orderStatus,
    required this.orderNumber,
    required this.centerId,
    required this.centerName,
    required this.centerPhone,
    required this.centerAddress,
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
