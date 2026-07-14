import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/get_admin_centers_use_case.dart';
import '../../domain/entities/admin_center_entity.dart';
import 'admin_centers_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class AdminCentersCubit extends Cubit<AdminCentersState> {
  final GetAdminCentersUseCase _getCentersUseCase;
  int _currentPage = 1;
  bool _isFetching = false;
  bool _hasReachedMax = false;

  AdminCentersCubit(this._getCentersUseCase) : super(const AdminCentersInitial());

  Future<void> fetchCenters({bool isRefresh = false, int limit = 10}) async {
    if (_isFetching) return;

    if (isRefresh) {
      _currentPage = 1;
      _hasReachedMax = false;
      emit(const AdminCentersInitial());
    }

    if (_hasReachedMax) return;

    _isFetching = true;
    if (state is! AdminCentersLoaded) {
      emit(const AdminCentersLoading());
    }

    final result = await _getCentersUseCase.call(
      page: _currentPage,
      limit: limit,
    );

    result.fold(
      (failure) {
        _isFetching = false;
        emit(AdminCentersError(failure.message));
      },
      (resultEntity) {
        _isFetching = false;
        _hasReachedMax = _currentPage >= resultEntity.pagination.pages;

        final currentCenters = state is AdminCentersLoaded
            ? (state as AdminCentersLoaded).centers
            : <AdminCenterEntity>[];

        final updatedCenters = isRefresh
            ? resultEntity.centers
            : [...currentCenters, ...resultEntity.centers];

        _currentPage++;
        emit(AdminCentersLoaded(updatedCenters, hasReachedMax: _hasReachedMax));
      },
    );
  }
}
