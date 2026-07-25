import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/get_financial_settings_use_case.dart';
import '../../domain/use_cases/update_financial_settings_use_case.dart';
import 'admin_financial_settings_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class AdminFinancialSettingsCubit extends Cubit<AdminFinancialSettingsState> {
  final GetFinancialSettingsUseCase _getFinancialSettingsUseCase;
  final UpdateFinancialSettingsUseCase _updateFinancialSettingsUseCase;

  AdminFinancialSettingsCubit(
    this._getFinancialSettingsUseCase,
    this._updateFinancialSettingsUseCase,
  ) : super(const AdminFinancialSettingsInitial());

  Future<void> fetchFinancialSettings() async {
    emit(const AdminFinancialSettingsLoading());
    final result = await _getFinancialSettingsUseCase.call();
    result.fold(
      (failure) => emit(AdminFinancialSettingsError(failure.message)),
      (settings) => emit(AdminFinancialSettingsLoaded(settings)),
    );
  }

  Future<void> updateFinancialSettings({
    required String commissionType,
    required double commissionValue,
    required String delegateFeeType,
    required double delegateFeeValue,
    required String currency,
    required bool isActive,
  }) async {
    final currentState = state;
    if (currentState is AdminFinancialSettingsLoaded) {
      emit(currentState.copyWith(
        isUpdating: true,
        error: null,
        successMessage: null,
      ));
    } else {
      emit(const AdminFinancialSettingsLoading());
    }

    final result = await _updateFinancialSettingsUseCase.call(
      commissionType: commissionType,
      commissionValue: commissionValue,
      delegateFeeType: delegateFeeType,
      delegateFeeValue: delegateFeeValue,
      currency: currency,
      isActive: isActive,
    );

    result.fold(
      (failure) {
        if (currentState is AdminFinancialSettingsLoaded) {
          emit(currentState.copyWith(
            isUpdating: false,
            error: failure.message,
          ));
        } else {
          emit(AdminFinancialSettingsError(failure.message));
        }
      },
      (updatedSettings) {
        emit(AdminFinancialSettingsLoaded(
          updatedSettings,
          isUpdating: false,
          successMessage: 'تم تحديث الإعدادات المالية بنجاح',
        ));
      },
    );
  }
}
