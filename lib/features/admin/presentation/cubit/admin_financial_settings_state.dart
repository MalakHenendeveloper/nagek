import '../../domain/entities/admin_financial_settings_entity.dart';

abstract class AdminFinancialSettingsState {
  const AdminFinancialSettingsState();
}

class AdminFinancialSettingsInitial extends AdminFinancialSettingsState {
  const AdminFinancialSettingsInitial();
}

class AdminFinancialSettingsLoading extends AdminFinancialSettingsState {
  const AdminFinancialSettingsLoading();
}

class AdminFinancialSettingsLoaded extends AdminFinancialSettingsState {
  final AdminFinancialSettingsEntity settings;
  final bool isUpdating;
  final String? successMessage;
  final String? error;

  const AdminFinancialSettingsLoaded(
    this.settings, {
    this.isUpdating = false,
    this.successMessage,
    this.error,
  });

  AdminFinancialSettingsLoaded copyWith({
    AdminFinancialSettingsEntity? settings,
    bool? isUpdating,
    String? successMessage,
    String? error,
  }) {
    return AdminFinancialSettingsLoaded(
      settings ?? this.settings,
      isUpdating: isUpdating ?? this.isUpdating,
      successMessage: successMessage,
      error: error,
    );
  }
}

class AdminFinancialSettingsError extends AdminFinancialSettingsState {
  final String message;

  const AdminFinancialSettingsError(this.message);
}
