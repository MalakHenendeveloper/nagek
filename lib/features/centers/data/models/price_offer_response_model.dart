import '../../domain/entities/price_offer_entity.dart';

class PriceOfferResponseModel {
  final bool success;
  final String message;
  final PriceOfferModel? offer;

  PriceOfferResponseModel({
    required this.success,
    required this.message,
    this.offer,
  });

  factory PriceOfferResponseModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    final data = map['data'] as Map? ?? {};
    final offerJson = data['offer'] as Map?;

    return PriceOfferResponseModel(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      offer: offerJson != null ? PriceOfferModel.fromJson(offerJson) : null,
    );
  }
}

class PriceOfferModel {
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

  PriceOfferModel({
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

  factory PriceOfferModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    return PriceOfferModel(
      id: map['_id'] ?? '',
      order: map['order'] ?? '',
      repairCenter: map['repairCenter'] ?? '',
      totalCost: (map['totalCost'] ?? 0).toDouble(),
      notes: map['notes'] ?? '',
      status: map['status'] ?? '',
      isDeleted: map['isDeleted'] ?? false,
      deletedAt: map['deletedAt'],
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
    );
  }

  PriceOfferEntity toEntity() {
    return PriceOfferEntity(
      id: id,
      order: order,
      repairCenter: repairCenter,
      totalCost: totalCost,
      notes: notes,
      status: status,
      isDeleted: isDeleted,
      deletedAt: deletedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
