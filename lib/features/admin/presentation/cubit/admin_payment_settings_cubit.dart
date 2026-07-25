import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/get_payment_settings_use_case.dart';
import '../../domain/use_cases/update_payment_settings_use_case.dart';
import 'admin_payment_settings_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class AdminPaymentSettingsCubit extends Cubit<AdminPaymentSettingsState> {
  final GetPaymentSettingsUseCase _getPaymentSettingsUseCase;
  final UpdatePaymentSettingsUseCase _updatePaymentSettingsUseCase;

  AdminPaymentSettingsCubit(
    this._getPaymentSettingsUseCase,
    this._updatePaymentSettingsUseCase,
  ) : super(const AdminPaymentSettingsInitial());

  Future<void> fetchPaymentSettings() async {
    emit(const AdminPaymentSettingsLoading());
    final result = await _getPaymentSettingsUseCase.call();
    result.fold(
      (failure) => emit(AdminPaymentSettingsError(failure.message)),
      (settings) => emit(AdminPaymentSettingsLoaded(settings)),
    );
  }

  Future<void> updatePaymentSettings({
    required String walletOwnerName,
    required Map<String, String> walletNumbers,
    required List<String> activePaymentMethods,
    required String paymentInstructions,
  }) async {
    final currentState = state;
    if (currentState is AdminPaymentSettingsLoaded) {
      emit(
        currentState.copyWith(
          isUpdating: true,
          error: null,
          successMessage: null,
        ),
      );
    } else {
      emit(const AdminPaymentSettingsLoading());
    }

    final result = await _updatePaymentSettingsUseCase.call(
      walletOwnerName: walletOwnerName,
      walletNumbers: walletNumbers,
      activePaymentMethods: activePaymentMethods,
      paymentInstructions: paymentInstructions,
    );

    result.fold(
      (failure) {
        if (currentState is AdminPaymentSettingsLoaded) {
          emit(
            currentState.copyWith(isUpdating: false, error: failure.message),
          );
        } else {
          emit(AdminPaymentSettingsError(failure.message));
        }
      },
      (updatedSettings) {
        emit(
          AdminPaymentSettingsLoaded(
            updatedSettings,
            isUpdating: false,
            successMessage: 'تم تحديث إعدادات الدفع بنجاح',
          ),
        );
      },
    );
  }
}
