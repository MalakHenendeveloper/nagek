import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../../domain/use_cases/get_admin_user_details_use_case.dart';
import '../../domain/use_cases/delete_admin_user_use_case.dart';
import '../../domain/use_cases/delete_admin_delegate_use_case.dart';
import '../../domain/use_cases/update_admin_user_status_use_case.dart';
import 'admin_user_details_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class AdminUserDetailsCubit extends Cubit<AdminUserDetailsState> {
  final GetAdminUserDetailsUseCase _getUserDetailsUseCase;
  final DeleteAdminUserUseCase _deleteUserUseCase;
  final DeleteAdminDelegateUseCase _deleteDelegateUseCase;
  final UpdateAdminUserStatusUseCase _updateUserStatusUseCase;

  AdminUserDetailsCubit(
    this._getUserDetailsUseCase,
    this._deleteUserUseCase,
    this._deleteDelegateUseCase,
    this._updateUserStatusUseCase,
  ) : super(const AdminUserDetailsInitial());

  Future<void> fetchUserDetails(String userId) async {
    emit(const AdminUserDetailsLoading());

    final result = await _getUserDetailsUseCase.call(userId);

    result.fold(
      (failure) => emit(AdminUserDetailsError(failure.message)),
      (user) => emit(AdminUserDetailsLoaded(user)),
    );
  }

  Future<void> deleteUser(String userId) async {
    final currentState = state;
    AdminUserEntity? user;
    if (currentState is AdminUserDetailsLoaded) {
      user = currentState.user;
    } else if (currentState is AdminUserStatusUpdateSuccess) {
      user = currentState.user;
    } else if (currentState is AdminUserStatusUpdateError) {
      user = currentState.user;
    }

    if (user != null) {
      emit(AdminUserDeleting(user));

      final result = user.role == 'delegate'
          ? await _deleteDelegateUseCase.call(userId)
          : await _deleteUserUseCase.call(userId);

      result.fold(
        (failure) => emit(AdminUserDeleteError(user!, failure.message)),
        (_) => emit(AdminUserDeleted(user!.role == 'delegate' ? 'تم حذف المندوب بنجاح' : 'تم حذف المستخدم بنجاح')),
      );
    }
  }

  Future<void> updateUserStatus(String userId, bool isActive) async {
    final currentState = state;
    AdminUserEntity? user;
    if (currentState is AdminUserDetailsLoaded) {
      user = currentState.user;
    } else if (currentState is AdminUserStatusUpdateSuccess) {
      user = currentState.user;
    } else if (currentState is AdminUserStatusUpdateError) {
      user = currentState.user;
    }

    if (user != null) {
      emit(AdminUserStatusUpdating(user));

      final result = await _updateUserStatusUseCase.call(
        userId: userId,
        isActive: isActive,
      );

      result.fold(
        (failure) => emit(AdminUserStatusUpdateError(user!, failure.message)),
        (updatedUser) {
          final finalUser = user!.copyWith(isActive: updatedUser.isActive);
          emit(AdminUserStatusUpdateSuccess(finalUser, 'تم تحديث حالة الحساب بنجاح'));
        },
      );
    }
  }
}
