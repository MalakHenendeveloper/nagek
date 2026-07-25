import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/use_cases/get_center_dashboard_use_case.dart';
import 'center_dashboard_state.dart';

@injectable
class CenterDashboardCubit extends Cubit<CenterDashboardState> {
  final GetCenterDashboardUseCase _getCenterDashboardUseCase;

  CenterDashboardCubit(this._getCenterDashboardUseCase)
      : super(CenterDashboardInitial());

  Future<void> fetchCenterDashboard() async {
    emit(CenterDashboardLoading());

    final result = await _getCenterDashboardUseCase.call();

    result.fold(
      (failure) => emit(CenterDashboardError(failure.message)),
      (dashboard) => emit(CenterDashboardLoaded(dashboard)),
    );
  }
}
