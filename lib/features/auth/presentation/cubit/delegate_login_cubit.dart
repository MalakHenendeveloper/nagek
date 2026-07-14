import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/delegate_login_result.dart';
import '../../domain/use_cases/delegate_login_use_case.dart';
import 'delegate_login_state.dart';

@injectable
class DelegateLoginCubit extends Cubit<DelegateLoginState> {
  final DelegateLoginUseCase _delegateLoginUseCase;

  DelegateLoginCubit(this._delegateLoginUseCase) : super(DelegateLoginInitial());

  Future<void> login({
    required String phone,
    required String password,
  }) async {
    emit(DelegateLoginLoading());

    final result = await _delegateLoginUseCase(
      phone: phone,
      password: password,
    );

    result.fold(
      (failure) => emit(DelegateLoginError(failure.message)),
      (loginResult) {
        if (loginResult is DelegateLoginSuccess) {
          emit(DelegateLoginSuccessState(loginResult.user));
        } else if (loginResult is DelegateLoginPending) {
          emit(DelegateLoginPendingState());
        } else if (loginResult is DelegateLoginRejected) {
          emit(DelegateLoginRejectedState(loginResult.rejectReason));
        }
      },
    );
  }
}
