import 'admin_user_entity.dart';
import 'admin_center_entity.dart';
import 'delegate_application_entity.dart';
import '../../../centers/domain/entities/center_entity.dart';

class AdminUsersResult {
  final List<AdminUserEntity> users;
  final PaginationEntity pagination;

  AdminUsersResult({
    required this.users,
    required this.pagination,
  });
}

class AdminDelegatesResult {
  final List<AdminUserEntity> delegates;
  final PaginationEntity pagination;

  AdminDelegatesResult({
    required this.delegates,
    required this.pagination,
  });
}

class AdminCentersResult {
  final List<AdminCenterEntity> centers;
  final PaginationEntity pagination;

  AdminCentersResult({
    required this.centers,
    required this.pagination,
  });
}

class AdminDelegateApplicationsResult {
  final List<DelegateApplicationEntity> applications;
  final PaginationEntity pagination;

  AdminDelegateApplicationsResult({
    required this.applications,
    required this.pagination,
  });
}
