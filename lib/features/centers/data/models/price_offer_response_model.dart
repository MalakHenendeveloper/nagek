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

class SparePartModel {
  final String name;
  final double cost;

  SparePartModel({required this.name, required this.cost});

  factory SparePartModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    return SparePartModel(
      name: map['name'] ?? '',
      cost: (map['cost'] ?? 0).toDouble(),
    );
  }

  SparePartEntity toEntity() => SparePartEntity(name: name, cost: cost);
}

class PriceOfferModel {
  final String id;
  final String order;
  final String repairCenter;
  final List<SparePartModel> spareParts;
  final double laborCost;
  final double inspectionFee;
  final double deliveryFee;
  final double totalCost;
  final int estimatedDays;
  final String notes;
  final String status;
  final String createdAt;

  PriceOfferModel({
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

  factory PriceOfferModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    final partsList = map['spareParts'] as List<dynamic>? ?? [];
    return PriceOfferModel(
      id: map['_id'] ?? '',
      order: map['order'] ?? '',
      repairCenter: map['repairCenter'] ?? '',
      spareParts: partsList.map((e) => SparePartModel.fromJson(e as Map?)).toList(),
      laborCost: (map['laborCost'] ?? 0).toDouble(),
      inspectionFee: (map['inspectionFee'] ?? 0).toDouble(),
      deliveryFee: (map['deliveryFee'] ?? 0).toDouble(),
      totalCost: (map['totalCost'] ?? 0).toDouble(),
      estimatedDays: (map['estimatedDays'] ?? 0).toInt(),
      notes: map['notes'] ?? '',
      status: map['status'] ?? '',
      createdAt: map['createdAt'] ?? '',
    );
  }

  PriceOfferEntity toEntity() {
    return PriceOfferEntity(
      id: id,
      order: order,
      repairCenter: repairCenter,
      spareParts: spareParts.map((m) => m.toEntity()).toList(),
      laborCost: laborCost,
      inspectionFee: inspectionFee,
      deliveryFee: deliveryFee,
      totalCost: totalCost,
      estimatedDays: estimatedDays,
      notes: notes,
      status: status,
      createdAt: createdAt,
    );
  }
}
