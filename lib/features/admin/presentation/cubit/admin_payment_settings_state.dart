import '../../domain/entities/admin_payment_settings_entity.dart';

abstract class AdminPaymentSettingsState {
  const AdminPaymentSettingsState();
}

class AdminPaymentSettingsInitial extends AdminPaymentSettingsState {
  const AdminPaymentSettingsInitial();
}

class AdminPaymentSettingsLoading extends AdminPaymentSettingsState {
  const AdminPaymentSettingsLoading();
}

class AdminPaymentSettingsLoaded extends AdminPaymentSettingsState {
  final AdminPaymentSettingsEntity settings;
  final bool isUpdating;
  final String? error;
  final String? successMessage;

  const AdminPaymentSettingsLoaded(
    this.settings, {
    this.isUpdating = false,
    this.error,
    this.successMessage,
  });

  AdminPaymentSettingsLoaded copyWith({
    AdminPaymentSettingsEntity? settings,
    bool? isUpdating,
    String? error,
    String? successMessage,
  }) {
    return AdminPaymentSettingsLoaded(
      settings ?? this.settings,
      isUpdating: isUpdating ?? this.isUpdating,
      error: error,
      successMessage: successMessage,
    );
  }
}

class AdminPaymentSettingsError extends AdminPaymentSettingsState {
  final String message;
  const AdminPaymentSettingsError(this.message);
}
