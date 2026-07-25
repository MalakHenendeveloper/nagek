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

  PriceOfferModel({
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

  factory PriceOfferModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    final order = map['order'];
    final repairCenter = map['repairCenter'];

    String orderId = '';
    String orderStatus = '';
    String orderNumber = '';

    if (order is Map) {
      orderId = order['_id'] ?? '';
      orderStatus = order['status'] ?? '';
      orderNumber = order['orderNumber'] ?? '';
    } else if (order is String) {
      orderId = order;
    }

    String centerId = '';
    String centerName = '';
    String centerPhone = '';
    String centerAddress = '';

    if (repairCenter is Map) {
      centerId = repairCenter['_id'] ?? '';
      centerName = repairCenter['name'] ?? '';
      centerPhone = repairCenter['phone'] ?? '';
      centerAddress = repairCenter['address'] ?? '';
    } else if (repairCenter is String) {
      centerId = repairCenter;
    }

    return PriceOfferModel(
      id: map['_id'] ?? '',
      orderId: orderId,
      orderStatus: orderStatus,
      orderNumber: orderNumber,
      centerId: centerId,
      centerName: centerName,
      centerPhone: centerPhone,
      centerAddress: centerAddress,
      totalCost: (map['totalCost'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes'] ?? '',
      status: map['status'] ?? 'pending',
      isDeleted: map['isDeleted'] ?? false,
      deletedAt: map['deletedAt'],
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
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
