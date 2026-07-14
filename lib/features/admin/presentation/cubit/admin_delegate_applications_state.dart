import '../../domain/entities/delegate_application_entity.dart';
import '../../../centers/domain/entities/center_entity.dart';

abstract class AdminDelegateApplicationsState {}

class AdminDelegateApplicationsInitial extends AdminDelegateApplicationsState {}

class AdminDelegateApplicationsLoading extends AdminDelegateApplicationsState {}

class AdminDelegateApplicationsSuccess extends AdminDelegateApplicationsState {
  final List<DelegateApplicationEntity> applications;
  final PaginationEntity pagination;
  final bool isLoadingMore;

  AdminDelegateApplicationsSuccess({
    required this.applications,
    required this.pagination,
    this.isLoadingMore = false,
  });

  AdminDelegateApplicationsSuccess copyWith({
    List<DelegateApplicationEntity>? applications,
    PaginationEntity? pagination,
    bool? isLoadingMore,
  }) {
    return AdminDelegateApplicationsSuccess(
      applications: applications ?? this.applications,
      pagination: pagination ?? this.pagination,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class AdminDelegateApplicationsError extends AdminDelegateApplicationsState {
  final String message;
  AdminDelegateApplicationsError(this.message);
}
