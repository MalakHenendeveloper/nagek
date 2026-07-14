import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/get_admin_users_use_case.dart';
import '../../domain/use_cases/get_admin_delegates_use_case.dart';
import '../../domain/use_cases/get_admin_centers_use_case.dart';
import 'admin_dashboard_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  final GetAdminUsersUseCase _getUsersUseCase;
  final GetAdminDelegatesUseCase _getDelegatesUseCase;
  final GetAdminCentersUseCase _getCentersUseCase;

  AdminDashboardCubit(
    this._getUsersUseCase,
    this._getDelegatesUseCase,
    this._getCentersUseCase,
  ) : super(const AdminDashboardInitial());

  Future<void> fetchDashboardStats() async {
    emit(const AdminDashboardLoading());

    final usersResult = await _getUsersUseCase.call(page: 1, limit: 1);
    final delegatesResult = await _getDelegatesUseCase.call(page: 1, limit: 1);
    final centersResult = await _getCentersUseCase.call(page: 1, limit: 1);

    int? totalUsers;
    int? totalDelegates;
    int? totalCenters;
    String? errorMessage;

    usersResult.fold(
      (failure) => errorMessage = failure.message,
      (result) => totalUsers = result.pagination.total,
    );

    if (errorMessage != null) {
      emit(AdminDashboardError(errorMessage!));
      return;
    }

    delegatesResult.fold(
      (failure) => errorMessage = failure.message,
      (result) => totalDelegates = result.pagination.total,
    );

    if (errorMessage != null) {
      emit(AdminDashboardError(errorMessage!));
      return;
    }

    centersResult.fold(
      (failure) => errorMessage = failure.message,
      (result) => totalCenters = result.pagination.total,
    );

    if (errorMessage != null) {
      emit(AdminDashboardError(errorMessage!));
      return;
    }

    emit(AdminDashboardLoaded(
      totalUsers: totalUsers ?? 0,
      totalDelegates: totalDelegates ?? 0,
      totalCenters: totalCenters ?? 0,
    ));
  }
}
