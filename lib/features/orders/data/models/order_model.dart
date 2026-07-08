import '../../domain/entities/order_entity.dart';

class DeviceModel {
  final String type;
  final String brand;
  final String model;
  final String problemType;
  final String problemDescription;
  final List<String> images;

  DeviceModel({
    required this.type,
    required this.brand,
    required this.model,
    required this.problemType,
    required this.problemDescription,
    required this.images,
  });

  factory DeviceModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    return DeviceModel(
      type: map['type'] ?? '',
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      problemType: map['problemType'] ?? '',
      problemDescription: map['problemDescription'] ?? '',
      images: List<String>.from(map['images'] ?? []),
    );
  }

  DeviceEntity toEntity() {
    return DeviceEntity(
      type: type,
      brand: brand,
      model: model,
      problemType: problemType,
      problemDescription: problemDescription,
      images: images,
    );
  }
}

class PickupAddressModel {
  final String address;
  final String city;

  PickupAddressModel({
    required this.address,
    required this.city,
  });

  factory PickupAddressModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    return PickupAddressModel(
      address: map['address'] ?? '',
      city: map['city'] ?? '',
    );
  }

  PickupAddressEntity toEntity() {
    return PickupAddressEntity(
      address: address,
      city: city,
    );
  }
}

class FeesModel {
  final double inspection;
  final double delivery;
  final double repair;
  final double total;

  FeesModel({
    required this.inspection,
    required this.delivery,
    required this.repair,
    required this.total,
  });

  factory FeesModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    return FeesModel(
      inspection: (map['inspection'] ?? 0.0).toDouble(),
      delivery: (map['delivery'] ?? 0.0).toDouble(),
      repair: (map['repair'] ?? 0.0).toDouble(),
      total: (map['total'] ?? 0.0).toDouble(),
    );
  }

  FeesEntity toEntity() {
    return FeesEntity(
      inspection: inspection,
      delivery: delivery,
      repair: repair,
      total: total,
    );
  }
}

class RepairCenterModel {
  final String id;
  final String name;
  final String phone;
  final String address;

  RepairCenterModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
  });

  factory RepairCenterModel.fromJson(dynamic json) {
    if (json is String) {
      return RepairCenterModel(
        id: json,
        name: '',
        phone: '',
        address: '',
      );
    } 
    final map = json as Map? ?? {};
    return RepairCenterModel(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
    );
  }

  RepairCenterEntity toEntity() {
    return RepairCenterEntity(
      id: id,
      name: name,
      phone: phone,
      address: address,
    );
  }
}

class StatusHistoryModel {
  final String status;
  final String note;
  final String updatedBy;
  final String timestamp;
  final String id;

  StatusHistoryModel({
    required this.status,
    required this.note,
    required this.updatedBy,
    required this.timestamp,
    required this.id,
  });

  factory StatusHistoryModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    return StatusHistoryModel(
      status: map['status'] ?? '',
      note: map['note'] ?? '',
      updatedBy: map['updatedBy'] ?? '',
      timestamp: map['timestamp'] ?? '',
      id: map['_id'] ?? '',
    );
  }

  StatusHistoryEntity toEntity() {
    return StatusHistoryEntity(
      status: status,
      note: note,
      updatedBy: updatedBy,
      timestamp: timestamp,
      id: id,
    );
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String status;
  final String paymentStatus;
  final DeviceModel device;
  final FeesModel fees;
  final PickupAddressModel pickupAddress;
  final RepairCenterModel repairCenter;
  final List<StatusHistoryModel> statusHistory;
  final String createdAt;
  final String updatedAt;
  final bool pickupOTPVerified;
  final bool deliveryOTPVerified;
  final String? clientApprovalStatus;
  final String? clientApprovalTimestamp;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.paymentStatus,
    required this.device,
    required this.fees,
    required this.pickupAddress,
    required this.repairCenter,
    required this.statusHistory,
    required this.createdAt,
    required this.updatedAt,
    required this.pickupOTPVerified,
    required this.deliveryOTPVerified,
    this.clientApprovalStatus,
    this.clientApprovalTimestamp,
  });

  factory OrderModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    final historyList = map['statusHistory'] as List<dynamic>? ?? [];
    final pickupOTP = map['pickupOTP'] as Map? ?? {};
    final deliveryOTP = map['deliveryOTP'] as Map? ?? {};
    final clientApproval = map['clientApproval'] as Map? ?? {};

    return OrderModel(
      id: map['_id'] ?? '',
      orderNumber: map['orderNumber'] ?? '',
      status: map['status'] ?? '',
      paymentStatus: map['paymentStatus'] ?? '',
      device: DeviceModel.fromJson(map['device'] as Map?),
      fees: FeesModel.fromJson(map['fees'] as Map?),
      pickupAddress: PickupAddressModel.fromJson(map['pickupAddress'] as Map?),
      repairCenter: RepairCenterModel.fromJson(map['repairCenter']),
      statusHistory: historyList.map((e) => StatusHistoryModel.fromJson(e as Map?)).toList(),
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
      pickupOTPVerified: pickupOTP['verified'] ?? false,
      deliveryOTPVerified: deliveryOTP['verified'] ?? false,
      clientApprovalStatus: clientApproval['status'],
      clientApprovalTimestamp: clientApproval['timestamp'],
    );
  }

  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      orderNumber: orderNumber,
      status: status,
      paymentStatus: paymentStatus,
      device: device.toEntity(),
      fees: fees.toEntity(),
      pickupAddress: pickupAddress.toEntity(),
      repairCenter: repairCenter.toEntity(),
      statusHistory: statusHistory.map((m) => m.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      pickupOTPVerified: pickupOTPVerified,
      deliveryOTPVerified: deliveryOTPVerified,
      clientApprovalStatus: clientApprovalStatus,
      clientApprovalTimestamp: clientApprovalTimestamp,
    );
  }
}

class OrdersPaginationModel {
  final int total;
  final int page;
  final int limit;
  final int pages;

  OrdersPaginationModel({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory OrdersPaginationModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    return OrdersPaginationModel(
      total: map['total'] ?? 0,
      page: map['page'] ?? 1,
      limit: map['limit'] ?? 10,
      pages: map['pages'] ?? 1,
    );
  }

  OrdersPaginationEntity toEntity() {
    return OrdersPaginationEntity(
      total: total,
      page: page,
      limit: limit,
      pages: pages,
    );
  }
}

class OrdersResponseModel {
  final bool success;
  final String message;
  final List<OrderModel> orders;
  final OrdersPaginationModel pagination;

  OrdersResponseModel({
    required this.success,
    required this.message,
    required this.orders,
    required this.pagination,
  });

  factory OrdersResponseModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    final data = map['data'] as Map? ?? {};
    final ordersList = data['orders'] as List<dynamic>? ?? [];
    
    return OrdersResponseModel(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      orders: ordersList.map((e) => OrderModel.fromJson(e as Map?)).toList(),
      pagination: OrdersPaginationModel.fromJson(map['pagination'] as Map?),
    );
  }
}
