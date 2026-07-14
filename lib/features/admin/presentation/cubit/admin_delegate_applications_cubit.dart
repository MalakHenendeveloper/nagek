import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/get_admin_delegate_applications_use_case.dart';
import '../../domain/entities/delegate_application_entity.dart';
import 'admin_delegate_applications_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class AdminDelegateApplicationsCubit extends Cubit<AdminDelegateApplicationsState> {
  final GetAdminDelegateApplicationsUseCase _getApplicationsUseCase;
  int _currentPage = 1;
  bool _isFetching = false;
  bool _hasReachedMax = false;

  AdminDelegateApplicationsCubit(this._getApplicationsUseCase)
      : super(AdminDelegateApplicationsInitial());

  Future<void> fetchApplications({bool isRefresh = false, int limit = 10}) async {
    if (_isFetching) return;

    if (isRefresh) {
      _currentPage = 1;
      _hasReachedMax = false;
      emit(AdminDelegateApplicationsInitial());
    }

    if (_hasReachedMax) return;

    _isFetching = true;
    if (state is! AdminDelegateApplicationsSuccess) {
      emit(AdminDelegateApplicationsLoading());
    }

    final result = await _getApplicationsUseCase.call(
      page: _currentPage,
      limit: limit,
    );

    result.fold(
      (failure) {
        _isFetching = false;
        emit(AdminDelegateApplicationsError(failure.message));
      },
      (resultEntity) {
        _isFetching = false;
        _hasReachedMax = _currentPage >= resultEntity.pagination.pages;

        final currentApplications = state is AdminDelegateApplicationsSuccess
            ? (state as AdminDelegateApplicationsSuccess).applications
            : <DelegateApplicationEntity>[];

        final updatedApplications = isRefresh
            ? resultEntity.applications
            : [...currentApplications, ...resultEntity.applications];

        _currentPage++;
        emit(AdminDelegateApplicationsSuccess(
          applications: updatedApplications,
          pagination: resultEntity.pagination,
        ));
      },
    );
  }
}
