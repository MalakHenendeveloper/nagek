import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/use_cases/get_admin_dashboard_use_case.dart';
import 'admin_dashboard_state.dart';

@injectable
class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  final GetAdminDashboardUseCase _getAdminDashboardUseCase;

  AdminDashboardCubit(this._getAdminDashboardUseCase)
      : super(const AdminDashboardInitial());

  Future<void> fetchDashboardStats() async {
    emit(const AdminDashboardLoading());

    final result = await _getAdminDashboardUseCase.call();

    result.fold(
      (failure) => emit(AdminDashboardError(failure.message)),
      (dashboard) => emit(AdminDashboardLoaded(dashboard)),
    );
  }
}
