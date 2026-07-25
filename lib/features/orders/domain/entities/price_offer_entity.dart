class PriceOfferEntity {
  final String id;
  final String orderId;
  final String orderStatus;
  final String orderNumber;
  final String centerId;
  final String centerName;
  final String centerPhone;
  final String centerAddress;
  final double totalCost;
  final String notes;
  final String status;
  final bool isDeleted;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;

  PriceOfferEntity({
    required this.id,
    required this.orderId,
    required this.orderStatus,
    required this.orderNumber,
    required this.centerId,
    required this.centerName,
    required this.centerPhone,
    required this.centerAddress,
    required this.totalCost,
    required this.notes,
    required this.status,
    required this.isDeleted,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });
}
