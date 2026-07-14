import '../../../centers/domain/entities/service_entity.dart';
import 'admin_center_entity.dart';

class AdminCenterStatisticsEntity {
  final int ordersCount;
  final int activeOrders;
  final int completedOrders;

  AdminCenterStatisticsEntity({
    required this.ordersCount,
    required this.activeOrders,
    required this.completedOrders,
  });
}

class AdminCenterDetailsEntity {
  final AdminCenterEntity center;
  final List<ServiceEntity> services;
  final AdminCenterStatisticsEntity statistics;

  AdminCenterDetailsEntity({
    required this.center,
    required this.services,
    required this.statistics,
  });
}
