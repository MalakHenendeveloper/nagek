import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/get_admin_delegates_use_case.dart';
import '../../domain/entities/admin_user_entity.dart';
import 'admin_delegates_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class AdminDelegatesCubit extends Cubit<AdminDelegatesState> {
  final GetAdminDelegatesUseCase _getDelegatesUseCase;
  int _currentPage = 1;
  bool _isFetching = false;
  bool _hasReachedMax = false;

  AdminDelegatesCubit(this._getDelegatesUseCase) : super(const AdminDelegatesInitial());

  Future<void> fetchDelegates({bool isRefresh = false, int limit = 10}) async {
    if (_isFetching) return;

    if (isRefresh) {
      _currentPage = 1;
      _hasReachedMax = false;
      emit(const AdminDelegatesInitial());
    }

    if (_hasReachedMax) return;

    _isFetching = true;
    if (state is! AdminDelegatesLoaded) {
      emit(const AdminDelegatesLoading());
    }

    final result = await _getDelegatesUseCase.call(
      page: _currentPage,
      limit: limit,
    );

    result.fold(
      (failure) {
        _isFetching = false;
        emit(AdminDelegatesError(failure.message));
      },
      (resultEntity) {
        _isFetching = false;
        _hasReachedMax = _currentPage >= resultEntity.pagination.pages;

        final currentDelegates = state is AdminDelegatesLoaded
            ? (state as AdminDelegatesLoaded).delegates
            : <AdminUserEntity>[];

        final updatedDelegates = isRefresh
            ? resultEntity.delegates
            : [...currentDelegates, ...resultEntity.delegates];

        _currentPage++;
        emit(AdminDelegatesLoaded(updatedDelegates, hasReachedMax: _hasReachedMax));
      },
    );
  }
}
