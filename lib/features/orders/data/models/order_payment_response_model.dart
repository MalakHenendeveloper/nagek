import '../../domain/entities/order_payment_entity.dart';
import 'order_model.dart';

class OrderPaymentResponseModel {
  final bool success;
  final String message;
  final OrderPaymentModel? data;

  OrderPaymentResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory OrderPaymentResponseModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    final dataMap = map['data'] as Map?;

    return OrderPaymentResponseModel(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      data: dataMap != null ? OrderPaymentModel.fromJson(dataMap) : null,
    );
  }
}

class OrderPaymentModel {
  final OrderModel order;
  final PaymentInfoModel? paymentInfo;
  final dynamic payment;
  final OrderPaymentFinancialViewModel financialView;

  OrderPaymentModel({
    required this.order,
    this.paymentInfo,
    this.payment,
    required this.financialView,
  });

  factory OrderPaymentModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    return OrderPaymentModel(
      order: OrderModel.fromJson(map['order'] as Map?),
      paymentInfo: map['paymentInfo'] != null
          ? PaymentInfoModel.fromJson(map['paymentInfo'] as Map?)
          : null,
      payment: map['payment'],
      financialView: OrderPaymentFinancialViewModel.fromJson(
        map['financialView'] as Map?,
      ),
    );
  }

  OrderPaymentEntity toEntity() {
    return OrderPaymentEntity(
      order: order.toEntity(),
      paymentInfo: paymentInfo?.toEntity(),
      payment: payment,
      financialView: financialView.toEntity(),
    );
  }
}

class PaymentInfoModel {
  final String walletOwnerName;
  final Map<String, String> walletNumbers;
  final List<String> availablePaymentMethods;
  final String paymentInstructions;

  PaymentInfoModel({
    required this.walletOwnerName,
    required this.walletNumbers,
    required this.availablePaymentMethods,
    required this.paymentInstructions,
  });

  factory PaymentInfoModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    final walletsRaw = map['walletNumbers'] as Map? ?? {};
    final walletNumbers = <String, String>{};
    walletsRaw.forEach((key, value) {
      walletNumbers[key.toString()] = value?.toString() ?? '';
    });

    final methodsRaw = map['availablePaymentMethods'] as List? ?? [];

    return PaymentInfoModel(
      walletOwnerName: map['walletOwnerName'] ?? '',
      walletNumbers: walletNumbers,
      availablePaymentMethods: methodsRaw.map((e) => e.toString()).toList(),
      paymentInstructions: map['paymentInstructions'] ?? '',
    );
  }

  PaymentInfoEntity toEntity() {
    return PaymentInfoEntity(
      walletOwnerName: walletOwnerName,
      walletNumbers: walletNumbers,
      availablePaymentMethods: availablePaymentMethods,
      paymentInstructions: paymentInstructions,
    );
  }
}

class PaymentBreakdownModel {
  final double repairCost;
  final double pickupFee;
  final double deliveryFee;
  final double adminFee;
  final double adminCommissionAmount;

  PaymentBreakdownModel({
    required this.repairCost,
    required this.pickupFee,
    required this.deliveryFee,
    required this.adminFee,
    required this.adminCommissionAmount,
  });

  factory PaymentBreakdownModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    final admin = (map['adminCommissionAmount'] ?? map['adminFee'] ?? map['adminCommission'] ?? 0).toDouble();
    return PaymentBreakdownModel(
      repairCost: (map['repairCost'] ?? map['repairAmount'] ?? 0).toDouble(),
      pickupFee: (map['pickupFee'] ?? map['inspectionFee'] ?? 0).toDouble(),
      deliveryFee: (map['deliveryFee'] ?? 0).toDouble(),
      adminFee: admin,
      adminCommissionAmount: admin,
    );
  }

  PaymentBreakdownEntity toEntity() {
    return PaymentBreakdownEntity(
      repairCost: repairCost,
      pickupFee: pickupFee,
      deliveryFee: deliveryFee,
      adminFee: adminFee,
      adminCommissionAmount: adminCommissionAmount,
    );
  }
}

class PaymentStageModel {
  final String stage;
  final String description;
  final double amount;

  PaymentStageModel({
    required this.stage,
    required this.description,
    required this.amount,
  });

  factory PaymentStageModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    return PaymentStageModel(
      stage: map['stage'] ?? '',
      description: map['description'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
    );
  }

  PaymentStageEntity toEntity() {
    return PaymentStageEntity(
      stage: stage,
      description: description,
      amount: amount,
    );
  }
}

class WalletInfoModel {
  final String walletOwnerName;
  final Map<String, String> walletNumbers;
  final String paymentInstructions;

  WalletInfoModel({
    required this.walletOwnerName,
    required this.walletNumbers,
    required this.paymentInstructions,
  });

  factory WalletInfoModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    final walletsRaw = map['walletNumbers'] as Map? ?? {};
    final walletNumbers = <String, String>{};
    walletsRaw.forEach((key, value) {
      walletNumbers[key.toString()] = value?.toString() ?? '';
    });

    return WalletInfoModel(
      walletOwnerName: map['walletOwnerName'] ?? '',
      walletNumbers: walletNumbers,
      paymentInstructions: map['paymentInstructions'] ?? '',
    );
  }

  WalletInfoEntity toEntity() {
    return WalletInfoEntity(
      walletOwnerName: walletOwnerName,
      walletNumbers: walletNumbers,
      paymentInstructions: paymentInstructions,
    );
  }
}

class OrderPaymentFinancialViewModel {
  final double orderTotal;
  final PaymentBreakdownModel? breakdown;
  final List<PaymentStageModel> payments;
  final String paymentStatus;
  final String currency;
  final WalletInfoModel? walletInfo;
  final dynamic paymentDetails;

  OrderPaymentFinancialViewModel({
    required this.orderTotal,
    this.breakdown,
    required this.payments,
    required this.paymentStatus,
    required this.currency,
    this.walletInfo,
    this.paymentDetails,
  });

  factory OrderPaymentFinancialViewModel.fromJson(Map<dynamic, dynamic>? json) {
    final map = json ?? {};
    final paymentsRaw = map['payments'] as List? ?? [];

    return OrderPaymentFinancialViewModel(
      orderTotal: (map['orderTotal'] ?? map['clientTotal'] ?? 0).toDouble(),
      breakdown: map['breakdown'] != null
          ? PaymentBreakdownModel.fromJson(map['breakdown'] as Map?)
          : null,
      payments: paymentsRaw
          .map((e) => PaymentStageModel.fromJson(e as Map?))
          .toList(),
      paymentStatus: map['paymentStatus'] ?? '',
      currency: map['currency'] ?? 'IQD',
      walletInfo: map['walletInfo'] != null
          ? WalletInfoModel.fromJson(map['walletInfo'] as Map?)
          : null,
      paymentDetails: map['paymentDetails'],
    );
  }

  OrderPaymentFinancialViewEntity toEntity() {
    return OrderPaymentFinancialViewEntity(
      orderTotal: orderTotal,
      breakdown: breakdown?.toEntity(),
      payments: payments.map((e) => e.toEntity()).toList(),
      paymentStatus: paymentStatus,
      currency: currency,
      walletInfo: walletInfo?.toEntity(),
      paymentDetails: paymentDetails,
    );
  }
}
