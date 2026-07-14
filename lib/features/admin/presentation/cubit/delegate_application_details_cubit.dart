import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/use_cases/get_delegate_application_details_use_case.dart';
import '../../domain/use_cases/approve_delegate_application_use_case.dart';
import '../../domain/use_cases/reject_delegate_application_use_case.dart';
import 'delegate_application_details_state.dart';

@injectable
class DelegateApplicationDetailsCubit extends Cubit<DelegateApplicationDetailsState> {
  final GetDelegateApplicationDetailsUseCase _getDetailsUseCase;
  final ApproveDelegateApplicationUseCase _approveUseCase;
  final RejectDelegateApplicationUseCase _rejectUseCase;

  DelegateApplicationDetailsCubit(
    this._getDetailsUseCase,
    this._approveUseCase,
    this._rejectUseCase,
  ) : super(DelegateApplicationDetailsInitial());

  Future<void> fetchDetails(String applicationId) async {
    emit(DelegateApplicationDetailsLoading());

    final result = await _getDetailsUseCase.call(applicationId);

    result.fold(
      (failure) => emit(DelegateApplicationDetailsError(failure.message)),
      (application) => emit(DelegateApplicationDetailsSuccess(application)),
    );
  }

  Future<void> approveApplication(String id) async {
    final currentState = state;
    if (currentState is DelegateApplicationDetailsSuccess) {
      emit(DelegateApplicationDetailsSuccess(
        currentState.application,
        isActionLoading: true,
      ));

      final result = await _approveUseCase.call(id);

      result.fold(
        (failure) {
          emit(DelegateApplicationDetailsSuccess(
            currentState.application,
            isActionLoading: false,
            actionError: failure.message,
          ));
          // Reset actionError so it doesn't stay in state
          emit(DelegateApplicationDetailsSuccess(currentState.application));
        },
        (_) => emit(DelegateApplicationApproveSuccess('تم قبول طلب المندوب بنجاح')),
      );
    }
  }

  Future<void> rejectApplication(String id, String rejectReason) async {
    final currentState = state;
    if (currentState is DelegateApplicationDetailsSuccess) {
      emit(DelegateApplicationDetailsSuccess(
        currentState.application,
        isActionLoading: true,
      ));

      final result = await _rejectUseCase.call(id, rejectReason);

      result.fold(
        (failure) {
          emit(DelegateApplicationDetailsSuccess(
            currentState.application,
            isActionLoading: false,
            actionError: failure.message,
          ));
          // Reset actionError so it doesn't stay in state
          emit(DelegateApplicationDetailsSuccess(currentState.application));
        },
        (_) => emit(DelegateApplicationRejectSuccess('تم رفض طلب المندوب بنجاح')),
      );
    }
  }
}
