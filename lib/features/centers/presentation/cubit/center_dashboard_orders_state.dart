import '../../../orders/domain/entities/order_entity.dart';

abstract class CenterDashboardOrdersState {}

class CenterDashboardOrdersInitial extends CenterDashboardOrdersState {}

class CenterDashboardOrdersLoading extends CenterDashboardOrdersState {}

class CenterDashboardOrdersLoaded extends CenterDashboardOrdersState {
  final List<OrderEntity> orders;
  final bool hasReachedMax;
  final int totalCount;
  final int pendingCount;
  final int inProgressCount;
  final int completedCount;

  CenterDashboardOrdersLoaded({
    required this.orders,
    required this.hasReachedMax,
    required this.totalCount,
    required this.pendingCount,
    required this.inProgressCount,
    required this.completedCount,
  });

  CenterDashboardOrdersLoaded copyWith({
    List<OrderEntity>? orders,
    bool? hasReachedMax,
    int? totalCount,
    int? pendingCount,
    int? inProgressCount,
    int? completedCount,
  }) {
    return CenterDashboardOrdersLoaded(
      orders: orders ?? this.orders,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      totalCount: totalCount ?? this.totalCount,
      pendingCount: pendingCount ?? this.pendingCount,
      inProgressCount: inProgressCount ?? this.inProgressCount,
      completedCount: completedCount ?? this.completedCount,
    );
  }
}

class CenterDashboardOrdersError extends CenterDashboardOrdersState {
  final String message;
  CenterDashboardOrdersError(this.message);
}
