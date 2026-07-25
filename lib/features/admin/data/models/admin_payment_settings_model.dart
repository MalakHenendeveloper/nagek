import '../../domain/entities/admin_payment_settings_entity.dart';

class WalletNumbersModel {
  final String zainCash;
  final String westernUnion;
  final String visa;
  final String mastercard;

  WalletNumbersModel({
    required this.zainCash,
    required this.westernUnion,
    required this.visa,
    required this.mastercard,
  });

  factory WalletNumbersModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    return WalletNumbersModel(
      zainCash: map['zain_cash'] ?? '',
      westernUnion: map['western_union'] ?? '',
      visa: map['visa'] ?? '',
      mastercard: map['mastercard'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zain_cash': zainCash,
      'western_union': westernUnion,
      'visa': visa,
      'mastercard': mastercard,
    };
  }

  WalletNumbersEntity toEntity() {
    return WalletNumbersEntity(
      zainCash: zainCash,
      westernUnion: westernUnion,
      visa: visa,
      mastercard: mastercard,
    );
  }
}

class AdminPaymentSettingsModel {
  final String walletOwnerName;
  final WalletNumbersModel walletNumbers;
  final List<String> activePaymentMethods;
  final String paymentInstructions;

  AdminPaymentSettingsModel({
    required this.walletOwnerName,
    required this.walletNumbers,
    required this.activePaymentMethods,
    required this.paymentInstructions,
  });

  factory AdminPaymentSettingsModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    return AdminPaymentSettingsModel(
      walletOwnerName: map['walletOwnerName'] ?? '',
      walletNumbers: WalletNumbersModel.fromJson(map['walletNumbers'] as Map?),
      activePaymentMethods: List<String>.from(map['activePaymentMethods'] ?? []),
      paymentInstructions: map['paymentInstructions'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'walletOwnerName': walletOwnerName,
      'walletNumbers': walletNumbers.toJson(),
      'activePaymentMethods': activePaymentMethods,
      'paymentInstructions': paymentInstructions,
    };
  }

  AdminPaymentSettingsEntity toEntity() {
    return AdminPaymentSettingsEntity(
      walletOwnerName: walletOwnerName,
      walletNumbers: walletNumbers.toEntity(),
      activePaymentMethods: activePaymentMethods,
      paymentInstructions: paymentInstructions,
    );
  }
}

class AdminPaymentSettingsResponseModel {
  final bool success;
  final String message;
  final AdminPaymentSettingsModel? data;

  AdminPaymentSettingsResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory AdminPaymentSettingsResponseModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    return AdminPaymentSettingsResponseModel(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      data: map['data'] != null ? AdminPaymentSettingsModel.fromJson(map['data'] as Map?) : null,
    );
  }
}
