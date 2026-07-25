class DeviceEntity {
  final String type;
  final String brand;
  final String model;
  final String problemType;
  final String problemDescription;
  final List<String> images;

  DeviceEntity({
    required this.type,
    required this.brand,
    required this.model,
    required this.problemType,
    required this.problemDescription,
    required this.images,
  });
}

class PickupAddressEntity {
  final String address;
  final String city;

  PickupAddressEntity({
    required this.address,
    required this.city,
  });
}

class FeesEntity {
  final double inspection;
  final double delivery;
  final double repair;
  final double total;
  final double delegateFeeValue;

  double get pickupFee => inspection;
  double get deliveryFee => delivery;

  FeesEntity({
    required this.inspection,
    required this.delivery,
    required this.repair,
    required this.total,
    this.delegateFeeValue = 0.0,
  });
}

class RepairCenterEntity {
  final String id;
  final String name;
  final String phone;
  final String address;

  RepairCenterEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
  });
}

class StatusHistoryEntity {
  final String status;
  final String note;
  final String updatedBy;
  final String timestamp;
  final String id;

  StatusHistoryEntity({
    required this.status,
    required this.note,
    required this.updatedBy,
    required this.timestamp,
    required this.id,
  });
}

class OrderClientEntity {
  final String id;
  final String name;
  final String phone;
  final String email;

  OrderClientEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
  });
}

class OrderDelegateEntity {
  final String id;
  final String name;
  final String phone;

  OrderDelegateEntity({
    required this.id,
    required this.name,
    required this.phone,
  });
}

class FinancialSnapshotEntity {
  final double repairAmount;
  final double inspectionFee;
  final double deliveryFee;
  final double clientTotal;
  final double adminCommission;
  final double delegateFee;
  final double centerAmount;
  final String currency;

  double get pickupFee => inspectionFee;

  FinancialSnapshotEntity({
    required this.repairAmount,
    required this.inspectionFee,
    required this.deliveryFee,
    required this.clientTotal,
    required this.adminCommission,
    required this.delegateFee,
    required this.centerAmount,
    required this.currency,
  });
}

class DelegatePhotosEntity {
  final List<String> atPickup;
  final List<String> atCenterDrop;
  final List<String> atCenterPickup;
  final List<String> atDelivery;

  DelegatePhotosEntity({
    required this.atPickup,
    required this.atCenterDrop,
    required this.atCenterPickup,
    required this.atDelivery,
  });
}

class OrderEntity {
  final String id;
  final String orderNumber;
  final String status;
  final String paymentStatus;
  final DeviceEntity device;
  final FeesEntity fees;
  final PickupAddressEntity pickupAddress;
  final RepairCenterEntity repairCenter;
  final List<StatusHistoryEntity> statusHistory;
  final String createdAt;
  final String updatedAt;
  final bool pickupOTPVerified;
  final bool deliveryOTPVerified;
  final String? clientApprovalStatus;
  final String? clientApprovalTimestamp;
  final OrderClientEntity? client;
  final OrderDelegateEntity? delegate;
  final OrderDelegateEntity? pickupDelegate;
  final OrderDelegateEntity? deliveryDelegate;
  final FinancialSnapshotEntity? financialSnapshot;
  final DelegatePhotosEntity? delegatePhotos;

  OrderEntity({
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
}

class OrdersPaginationEntity {
  final int total;
  final int page;
  final int limit;
  final int pages;

  OrdersPaginationEntity({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });
}

class OrdersResultEntity {
  final List<OrderEntity> orders;
  final OrdersPaginationEntity pagination;

  OrdersResultEntity({
    required this.orders,
    required this.pagination,
  });
}

class OrderTrackingEntity {
  final String orderNumber;
  final String status;
  final List<StatusHistoryEntity> statusHistory;

  OrderTrackingEntity({
    required this.orderNumber,
    required this.status,
    required this.statusHistory,
  });
}
