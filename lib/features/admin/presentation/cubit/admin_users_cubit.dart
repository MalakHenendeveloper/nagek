import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/get_admin_users_use_case.dart';
import '../../domain/entities/admin_user_entity.dart';
import 'admin_users_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class AdminUsersCubit extends Cubit<AdminUsersState> {
  final GetAdminUsersUseCase _getUsersUseCase;
  int _currentPage = 1;
  bool _isFetching = false;
  bool _hasReachedMax = false;

  AdminUsersCubit(this._getUsersUseCase) : super(const AdminUsersInitial());

  Future<void> fetchUsers({bool isRefresh = false, int limit = 10}) async {
    if (_isFetching) return;

    if (isRefresh) {
      _currentPage = 1;
      _hasReachedMax = false;
      emit(const AdminUsersInitial());
    }

    if (_hasReachedMax) return;

    _isFetching = true;
    if (state is! AdminUsersLoaded) {
      emit(const AdminUsersLoading());
    }

    final result = await _getUsersUseCase.call(
      page: _currentPage,
      limit: limit,
    );

    result.fold(
      (failure) {
        _isFetching = false;
        emit(AdminUsersError(failure.message));
      },
      (resultEntity) {
        _isFetching = false;
        _hasReachedMax = _currentPage >= resultEntity.pagination.pages;

        final currentUsers = state is AdminUsersLoaded
            ? (state as AdminUsersLoaded).users
            : <AdminUserEntity>[];

        final updatedUsers = isRefresh
            ? resultEntity.users
            : [...currentUsers, ...resultEntity.users];

        _currentPage++;
        emit(AdminUsersLoaded(updatedUsers, hasReachedMax: _hasReachedMax));
      },
    );
  }
}
