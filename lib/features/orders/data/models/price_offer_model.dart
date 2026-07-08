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
  final String id;
  final String name;
  final double cost;

  SparePartModel({
    required this.id,
    required this.name,
    required this.cost,
  });

  factory SparePartModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    return SparePartModel(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      cost: (map['cost'] as num?)?.toDouble() ?? 0.0,
    );
  }

  SparePartEntity toEntity() {
    return SparePartEntity(
      id: id,
      name: name,
      cost: cost,
    );
  }
}

class PriceOfferModel {
  final String id;
  final String orderId;
  final String orderStatus;
  final String orderNumber;
  final String centerId;
  final String centerName;
  final String centerPhone;
  final String centerAddress;
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

  factory PriceOfferModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    final order = map['order'] as Map? ?? {};
    final repairCenter = map['repairCenter'] as Map? ?? {};
    final sparePartsList = map['spareParts'] as List<dynamic>? ?? [];

    return PriceOfferModel(
      id: map['_id'] ?? '',
      orderId: order['_id'] ?? '',
      orderStatus: order['status'] ?? '',
      orderNumber: order['orderNumber'] ?? '',
      centerId: repairCenter['_id'] ?? '',
      centerName: repairCenter['name'] ?? '',
      centerPhone: repairCenter['phone'] ?? '',
      centerAddress: repairCenter['address'] ?? '',
      spareParts: sparePartsList.map((e) => SparePartModel.fromJson(e as Map?)).toList(),
      laborCost: (map['laborCost'] as num?)?.toDouble() ?? 0.0,
      inspectionFee: (map['inspectionFee'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (map['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      totalCost: (map['totalCost'] as num?)?.toDouble() ?? 0.0,
      estimatedDays: map['estimatedDays'] ?? 0,
      notes: map['notes'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] ?? '',
    );
  }

  PriceOfferEntity toEntity() {
    return PriceOfferEntity(
      id: id,
      orderId: orderId,
      orderStatus: orderStatus,
      orderNumber: orderNumber,
      centerId: centerId,
      centerName: centerName,
      centerPhone: centerPhone,
      centerAddress: centerAddress,
      spareParts: spareParts.map((e) => e.toEntity()).toList(),
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
