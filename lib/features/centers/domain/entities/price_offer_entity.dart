class PriceOfferEntity {
  final String id;
  final String order;
  final String repairCenter;
  final double totalCost;
  final String notes;
  final String status;
  final bool isDeleted;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;

  PriceOfferEntity({
    required this.id,
    required this.order,
    required this.repairCenter,
    required this.totalCost,
    required this.notes,
    required this.status,
    required this.isDeleted,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });
}
