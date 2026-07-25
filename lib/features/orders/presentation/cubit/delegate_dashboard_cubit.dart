import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/use_cases/get_delegate_dashboard_use_case.dart';
import 'delegate_dashboard_state.dart';

@injectable
class DelegateDashboardCubit extends Cubit<DelegateDashboardState> {
  final GetDelegateDashboardUseCase _getDelegateDashboardUseCase;

  DelegateDashboardCubit(this._getDelegateDashboardUseCase)
      : super(DelegateDashboardInitial());

  Future<void> fetchDelegateDashboard() async {
    emit(DelegateDashboardLoading());

    final result = await _getDelegateDashboardUseCase.call();

    result.fold(
      (failure) => emit(DelegateDashboardError(failure.message)),
      (dashboard) => emit(DelegateDashboardLoaded(dashboard)),
    );
  }
}
