import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/use_cases/get_admin_settlements_report_use_case.dart';
import '../../domain/use_cases/update_order_settlement_use_case.dart';
import 'admin_settlements_report_state.dart';

@injectable
class AdminSettlementsReportCubit extends Cubit<AdminSettlementsReportState> {
  final GetAdminSettlementsReportUseCase _getAdminSettlementsReportUseCase;
  final UpdateOrderSettlementUseCase _updateOrderSettlementUseCase;

  AdminSettlementsReportCubit(
    this._getAdminSettlementsReportUseCase,
    this._updateOrderSettlementUseCase,
  ) : super(AdminSettlementsReportInitial());

  Future<void> fetchReport({bool silent = false}) async {
    if (!silent) {
      emit(AdminSettlementsReportLoading());
    }
    final result = await _getAdminSettlementsReportUseCase();
    result.fold(
      (failure) => emit(AdminSettlementsReportError(failure.message)),
      (report) => emit(AdminSettlementsReportLoaded(report)),
    );
  }

  Future<bool> updateSettlement({
    required String orderId,
    required String party,
    required bool settled,
  }) async {
    final key = '$orderId-$party';
    final currentState = state;
    if (currentState is AdminSettlementsReportLoaded) {
      emit(currentState.copyWith(updatingKey: key));
    }

    final result = await _updateOrderSettlementUseCase(
      orderId: orderId,
      party: party,
      settled: settled,
    );

    return result.fold(
      (failure) {
        if (state is AdminSettlementsReportLoaded) {
          emit((state as AdminSettlementsReportLoaded).copyWith(
            clearUpdatingKey: true,
            actionErrorMessage: failure.message,
          ));
        }
        return false;
      },
      (success) async {
        await fetchReport(silent: true);
        if (state is AdminSettlementsReportLoaded) {
          emit((state as AdminSettlementsReportLoaded).copyWith(
            clearUpdatingKey: true,
            actionSuccessMessage: settled ? 'تمت التسوية بنجاح ✅' : 'تم إلغاء التسوية بنجاح',
          ));
        }
        return true;
      },
    );
  }
}
