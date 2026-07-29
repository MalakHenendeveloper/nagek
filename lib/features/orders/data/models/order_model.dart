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
      type: map['type'] ?? map['deviceType'] ?? '',
      brand: map['brand'] ?? map['deviceBrand'] ?? '',
      model: map['model'] ?? map['deviceModel'] ?? '',
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
  final double delegateFeeValue;

  FeesModel({
    required this.inspection,
    required this.delivery,
    required this.repair,
    required this.total,
    this.delegateFeeValue = 0.0,
  });

  factory FeesModel.fromJson(Map<dynamic, dynamic>? json, {double? rootDelegateFeeValue, double? rootRepairCost}) {
    final map = json ?? {};
    // fees-level delegateFeeValue (rarely set, usually 0)
    final feeLevelVal = (map['delegateFeeValue'] is num && (map['delegateFeeValue'] as num) > 0)
        ? (map['delegateFeeValue'] as num).toDouble()
        : (map['delegateFee'] is num && (map['delegateFee'] as num) > 0)
            ? (map['delegateFee'] as num).toDouble()
            : null;
    final feeVal = feeLevelVal ?? rootDelegateFeeValue ?? 0.0;

    final double? rawRepair = (map['repair'] is num && (map['repair'] as num) > 0)
        ? (map['repair'] as num).toDouble()
        : (map['repairCost'] is num && (map['repairCost'] as num) > 0)
            ? (map['repairCost'] as num).toDouble()
            : (map['repairAmount'] is num && (map['repairAmount'] as num) > 0)
                ? (map['repairAmount'] as num).toDouble()
                : (map['centerAmount'] is num && (map['centerAmount'] as num) > 0)
                    ? (map['centerAmount'] as num).toDouble()
                    : (map['price'] is num && (map['price'] as num) > 0)
                        ? (map['price'] as num).toDouble()
                        : null;

    final repairVal = rawRepair ?? rootRepairCost ?? 0.0;

    final double rawTotal = (map['total'] is num && (map['total'] as num) > 0)
        ? (map['total'] as num).toDouble()
        : (map['totalCost'] is num && (map['totalCost'] as num) > 0)
            ? (map['totalCost'] as num).toDouble()
            : (map['clientTotal'] is num && (map['clientTotal'] as num) > 0)
                ? (map['clientTotal'] as num).toDouble()
                : 0.0;

    return FeesModel(
      inspection: ((map['inspection'] ?? map['inspectionFee'] ?? 0.0) as num).toDouble(),
      delivery: ((map['delivery'] ?? map['deliveryFee'] ?? 0.0) as num).toDouble(),
      repair: repairVal,
      total: rawTotal > 0 ? rawTotal : repairVal,
      delegateFeeValue: feeVal,
    );
  }

  FeesEntity toEntity() {
    return FeesEntity(
      inspection: inspection,
      delivery: delivery,
      repair: repair,
      total: total,
      delegateFeeValue: delegateFeeValue,
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
    if (json == null) {
      return RepairCenterModel(
        id: '',
        name: '',
        phone: '',
        address: '',
      );
    }
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
      id: map['_id'] ?? map['id'] ?? map['repairCenterId'] ?? '',
      name: map['name'] ?? map['repairCenterName'] ?? '',
      phone: map['phone'] ?? map['repairCenterPhone'] ?? '',
      address: map['address'] ?? map['repairCenterAddress'] ?? '',
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
    final updatedByVal = map['updatedBy'];
    String updatedByStr = '';
    if (updatedByVal is Map) {
      updatedByStr = (updatedByVal['name'] ?? updatedByVal['_id'] ?? '').toString();
    } else if (updatedByVal != null) {
      updatedByStr = updatedByVal.toString();
    }

    return StatusHistoryModel(
      status: map['status'] ?? '',
      note: map['note'] ?? map['notes'] ?? '',
      updatedBy: updatedByStr,
      timestamp: map['timestamp'] ?? map['createdAt'] ?? '',
      id: map['_id'] ?? map['id'] ?? '',
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

class OrderClientModel {
  final String id;
  final String name;
  final String phone;
  final String email;

  OrderClientModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
  });

  factory OrderClientModel.fromJson(dynamic json) {
    if (json == null) {
      return OrderClientModel(id: '', name: '', phone: '', email: '');
    }
    if (json is String) {
      return OrderClientModel(id: json, name: '', phone: '', email: '');
    }
    final map = json as Map? ?? {};
    return OrderClientModel(
      id: map['_id'] ?? map['id'] ?? map['clientId'] ?? '',
      name: map['name'] ?? map['clientName'] ?? '',
      phone: map['phone'] ?? map['clientPhone'] ?? '',
      email: map['email'] ?? map['clientEmail'] ?? '',
    );
  }

  OrderClientEntity toEntity() {
    return OrderClientEntity(
      id: id,
      name: name,
      phone: phone,
      email: email,
    );
  }
}

class OrderDelegateModel {
  final String id;
  final String name;
  final String phone;

  OrderDelegateModel({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory OrderDelegateModel.fromJson(dynamic json) {
    if (json == null) {
      return OrderDelegateModel(id: '', name: '', phone: '');
    }
    if (json is String) {
      return OrderDelegateModel(id: json, name: '', phone: '');
    }
    final map = json as Map? ?? {};
    return OrderDelegateModel(
      id: map['_id'] ?? map['id'] ?? map['delegateId'] ?? '',
      name: map['name'] ?? map['assignedDelegateName'] ?? map['pickupDelegateName'] ?? map['deliveryDelegateName'] ?? '',
      phone: map['phone'] ?? map['assignedDelegatePhone'] ?? map['pickupDelegatePhone'] ?? map['deliveryDelegatePhone'] ?? '',
    );
  }

  OrderDelegateEntity toEntity() {
    return OrderDelegateEntity(
      id: id,
      name: name,
      phone: phone,
    );
  }
}

class FinancialSnapshotModel {
  final double repairAmount;
  final double inspectionFee;
  final double deliveryFee;
  final double clientTotal;
  final double adminCommission;
  final double delegateFee;
  final double centerAmount;
  final String currency;

  FinancialSnapshotModel({
    required this.repairAmount,
    required this.inspectionFee,
    required this.deliveryFee,
    required this.clientTotal,
    required this.adminCommission,
    required this.delegateFee,
    required this.centerAmount,
    required this.currency,
  });

  factory FinancialSnapshotModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    final pFee = ((map['pickupFee'] ?? map['inspectionFee'] ?? map['inspection'] ?? 0.0) as num).toDouble();
    final dFee = ((map['deliveryFee'] ?? map['delivery'] ?? 0.0) as num).toDouble();
    final rAmt = ((map['repairAmount'] ?? map['repairCost'] ?? map['repair'] ?? map['serviceCost'] ?? map['price'] ?? 0.0) as num).toDouble();
    final cAmt = ((map['centerAmount'] ?? map['centerPayout'] ?? map['repairIncome'] ?? 0.0) as num).toDouble();
    final resolvedCenterAmt = cAmt > 0 ? cAmt : rAmt;
    final cTotal = ((map['clientTotal'] ?? map['total'] ?? map['totalCost'] ?? 0.0) as num).toDouble();

    return FinancialSnapshotModel(
      repairAmount: rAmt,
      inspectionFee: pFee,
      deliveryFee: dFee,
      clientTotal: cTotal > 0 ? cTotal : (rAmt + dFee + pFee),
      adminCommission: ((map['adminCommission'] ?? 0.0) as num).toDouble(),
      delegateFee: ((map['delegateFee'] ?? dFee) as num).toDouble(),
      centerAmount: resolvedCenterAmt,
      currency: (map['currency'] ?? 'IQD').toString(),
    );
  }

  FinancialSnapshotEntity toEntity() {
    return FinancialSnapshotEntity(
      repairAmount: repairAmount,
      inspectionFee: inspectionFee,
      deliveryFee: deliveryFee,
      clientTotal: clientTotal,
      adminCommission: adminCommission,
      delegateFee: delegateFee,
      centerAmount: centerAmount,
      currency: currency,
    );
  }
}

class DelegatePhotosModel {
  final List<String> atPickup;
  final List<String> atCenterDrop;
  final List<String> atCenterPickup;
  final List<String> atDelivery;

  DelegatePhotosModel({
    required this.atPickup,
    required this.atCenterDrop,
    required this.atCenterPickup,
    required this.atDelivery,
  });

  factory DelegatePhotosModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    return DelegatePhotosModel(
      atPickup: List<String>.from(map['atPickup'] ?? []),
      atCenterDrop: List<String>.from(map['atCenterDrop'] ?? []),
      atCenterPickup: List<String>.from(map['atCenterPickup'] ?? []),
      atDelivery: List<String>.from(map['atDelivery'] ?? []),
    );
  }

  DelegatePhotosEntity toEntity() {
    return DelegatePhotosEntity(
      atPickup: atPickup,
      atCenterDrop: atCenterDrop,
      atCenterPickup: atCenterPickup,
      atDelivery: atDelivery,
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
  final OrderClientModel? client;
  final OrderDelegateModel? delegate;
  final OrderDelegateModel? pickupDelegate;
  final OrderDelegateModel? deliveryDelegate;
  final FinancialSnapshotModel? financialSnapshot;
  final DelegatePhotosModel? delegatePhotos;

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
    this.client,
    this.delegate,
    this.pickupDelegate,
    this.deliveryDelegate,
    this.financialSnapshot,
    this.delegatePhotos,
  });

  factory OrderModel.fromJson(Map<dynamic, dynamic>? json, {double? rootDelegateFeeValue}) {
    final map = json ?? {};
    final historyList = map['statusHistory'] as List<dynamic>? ?? [];
    final pickupOTP = map['pickupOTP'] as Map? ?? {};
    final deliveryOTP = map['deliveryOTP'] as Map? ?? {};
    final clientApproval = map['clientApproval'] as Map? ?? {};

    final clientData = map['client'] ?? (map.containsKey('clientName') && map['clientName'].toString().isNotEmpty ? map : null);

    final pickupDelegateData = map['pickupDelegate'] ?? (map.containsKey('pickupDelegateName') && map['pickupDelegateName'].toString().isNotEmpty ? {
      'name': map['pickupDelegateName'],
      'phone': map['pickupDelegatePhone'] ?? map['assignedDelegatePhone'] ?? '',
    } : null);

    final deliveryDelegateData = map['deliveryDelegate'] ?? (map.containsKey('deliveryDelegateName') && map['deliveryDelegateName'].toString().isNotEmpty ? {
      'name': map['deliveryDelegateName'],
      'phone': map['deliveryDelegatePhone'] ?? map['assignedDelegatePhone'] ?? '',
    } : null);

    final delegateData = map['delegate'] ?? pickupDelegateData ?? deliveryDelegateData ??
        (map.containsKey('assignedDelegateName') && map['assignedDelegateName'].toString().isNotEmpty ? {
          'name': map['assignedDelegateName'],
          'phone': map['assignedDelegatePhone'] ?? '',
        } : null);

    final deviceData = map['device'] ?? (map.containsKey('deviceBrand') || map.containsKey('deviceType') ? map : null);
    final centerData = map['repairCenter'] ?? (map.containsKey('repairCenterName') ? map : null);

    final finView = map['financialView'] as Map?;
    final finSnap = map['financialSnapshot'] as Map?;
    final double? finRepairCost = finView != null
        ? ((finView['repairCost'] is num) ? (finView['repairCost'] as num).toDouble() : null)
        : null;

    final double? rootRepairVal = finRepairCost ??
        ((map['repairCost'] is num) ? (map['repairCost'] as num).toDouble() : null) ??
        ((map['repairAmount'] is num) ? (map['repairAmount'] as num).toDouble() : null) ??
        ((map['centerAmount'] is num) ? (map['centerAmount'] as num).toDouble() : null) ??
        ((map['serviceCost'] is num) ? (map['serviceCost'] as num).toDouble() : null) ??
        ((map['price'] is num) ? (map['price'] as num).toDouble() : null) ??
        (finSnap != null
            ? (((finSnap['repairAmount'] ?? finSnap['repairCost'] ?? finSnap['centerAmount']) is num)
                ? ((finSnap['repairAmount'] ?? finSnap['repairCost'] ?? finSnap['centerAmount']) as num).toDouble()
                : null)
            : null);

    // Priority: rootDelegateFeeValue (from parent data) > map['delegateFeeValue'] > map['delegateFee']
    final double? resolvedDelegateFee = rootDelegateFeeValue ??
        ((map['delegateFeeValue'] is num) ? (map['delegateFeeValue'] as num).toDouble() : null) ??
        ((map['delegateFee'] is num) ? (map['delegateFee'] as num).toDouble() : null);

    return OrderModel(
      id: map['_id'] ?? map['id'] ?? map['orderId'] ?? '',
      orderNumber: map['orderNumber'] ?? '',
      status: map['status'] ?? '',
      paymentStatus: map['paymentStatus'] ?? '',
      device: DeviceModel.fromJson(deviceData as Map?),
      fees: FeesModel.fromJson(
        map['fees'] as Map?,
        rootDelegateFeeValue: resolvedDelegateFee,
        rootRepairCost: rootRepairVal,
      ),
      pickupAddress: PickupAddressModel.fromJson(map['pickupAddress'] as Map?),
      repairCenter: RepairCenterModel.fromJson(centerData),
      statusHistory: historyList.map((e) => StatusHistoryModel.fromJson(e as Map?)).toList(),
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
      pickupOTPVerified: pickupOTP['verified'] ?? false,
      deliveryOTPVerified: deliveryOTP['verified'] ?? false,
      clientApprovalStatus: clientApproval['status'],
      clientApprovalTimestamp: clientApproval['timestamp'],
      client: clientData != null ? OrderClientModel.fromJson(clientData) : null,
      delegate: delegateData != null ? OrderDelegateModel.fromJson(delegateData) : null,
      pickupDelegate: pickupDelegateData != null ? OrderDelegateModel.fromJson(pickupDelegateData) : null,
      deliveryDelegate: deliveryDelegateData != null ? OrderDelegateModel.fromJson(deliveryDelegateData) : null,
      financialSnapshot: map['financialSnapshot'] != null ? FinancialSnapshotModel.fromJson(map['financialSnapshot'] as Map?) : null,
      delegatePhotos: map['delegatePhotos'] != null ? DelegatePhotosModel.fromJson(map['delegatePhotos'] as Map?) : null,
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
      client: client?.toEntity(),
      delegate: delegate?.toEntity(),
      pickupDelegate: pickupDelegate?.toEntity(),
      deliveryDelegate: deliveryDelegate?.toEntity(),
      financialSnapshot: financialSnapshot?.toEntity(),
      delegatePhotos: delegatePhotos?.toEntity(),
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
