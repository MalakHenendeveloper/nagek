import '../../domain/entities/admin_financial_settings_entity.dart';

class AdminFinancialSettingsModel {
  final String commissionType;
  final double commissionValue;
  final String delegateFeeType;
  final double delegateFeeValue;
  final String currency;
  final bool isActive;

  AdminFinancialSettingsModel({
    required this.commissionType,
    required this.commissionValue,
    required this.delegateFeeType,
    required this.delegateFeeValue,
    required this.currency,
    required this.isActive,
  });

  factory AdminFinancialSettingsModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    return AdminFinancialSettingsModel(
      commissionType: map['commissionType'] ?? 'percentage',
      commissionValue: (map['commissionValue'] ?? 0).toDouble(),
      delegateFeeType: map['delegateFeeType'] ?? 'fixed',
      delegateFeeValue: (map['delegateFeeValue'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'IQD',
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commissionType': commissionType,
      'commissionValue': commissionValue,
      'delegateFeeType': delegateFeeType,
      'delegateFeeValue': delegateFeeValue,
      'currency': currency,
      'isActive': isActive,
    };
  }

  AdminFinancialSettingsEntity toEntity() {
    return AdminFinancialSettingsEntity(
      commissionType: commissionType,
      commissionValue: commissionValue,
      delegateFeeType: delegateFeeType,
      delegateFeeValue: delegateFeeValue,
      currency: currency,
      isActive: isActive,
    );
  }
}

class AdminFinancialSettingsResponseModel {
  final bool success;
  final String message;
  final AdminFinancialSettingsModel? data;

  AdminFinancialSettingsResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory AdminFinancialSettingsResponseModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    final dataMap = map['data'] as Map?;
    final settingsMap = (dataMap != null && dataMap['settings'] != null)
        ? dataMap['settings'] as Map?
        : dataMap;

    return AdminFinancialSettingsResponseModel(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      data: settingsMap != null
          ? AdminFinancialSettingsModel.fromJson(settingsMap)
          : null,
    );
  }
}
