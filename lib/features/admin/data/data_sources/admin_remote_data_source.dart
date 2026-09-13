import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:http_parser/http_parser.dart' show MediaType;
import '../../../../core/api/api_manager.dart';
import '../../../../core/api/endpoints.dart';
import '../models/admin_responses.dart';
import '../models/delegate_application_model.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../orders/data/models/order_details_response_model.dart';
import '../models/admin_payments_response_model.dart';
import '../models/admin_payment_settings_model.dart';
import '../models/admin_financial_settings_model.dart';
import '../models/admin_dashboard_response_model.dart';
import '../models/admin_settlements_response_model.dart';
import '../models/admin_settlements_summary_response_model.dart';
import '../models/admin_pay_settlement_response_model.dart';
import '../models/coupon_response_model.dart';
import '../models/coupons_list_response_model.dart';
import '../models/admin_settlements_report_response_model.dart';
import '../models/admin_update_order_settlement_response_model.dart';
import 'package:injectable/injectable.dart';

abstract class AdminRemoteDataSource {
  Future<AdminUpdateOrderSettlementResponseModel> updateOrderSettlement({
    required String orderId,
    required String party,
    required bool settled,
  });
  Future<AdminSettlementsReportResponseModel> getAdminSettlementsReport();
  Future<AdminDashboardResponseModel> getAdminDashboard();

  Future<AdminPaySettlementResponseModel> payAdminSettlement(
    String settlementId, {
    String? paymentMethod,
    String? notes,
  });

  Future<AdminSettlementsSummaryResponseModel> getAdminSettlementsSummary({
    required int page,
    required int limit,
    String? recipientType,
    String? search,
    String? sortBy,
    String? sortOrder,
  });

  Future<AdminSettlementsResponseModel> getAdminSettlements({
    required int page,
    required int limit,
    String? status,
    String? recipientType,
    String? recipientId,
    String? order,
    String? paymentMethod,
    String? dateFrom,
    String? dateTo,
    String? sort,
  });
  Future<OrdersResponseModel> getOrders({required int page, required int limit});
  Future<OrderDetailsResponseModel> getOrderDetails(String orderId);
  Future<AdminUsersResponseModel> getUsers({required int page, required int limit});
  Future<AdminDelegatesResponseModel> getDelegates({required int page, required int limit});
  Future<AdminCentersResponseModel> getCenters({required int page, required int limit});
  Future<AdminUserDetailsResponseModel> getUserDetails(String userId);
  Future<AdminCenterDetailsResponseModel> getCenterDetails(String centerId);
  Future<AdminUserDetailsResponseModel> deleteUser(String userId);
  Future<AdminUserDetailsResponseModel> deleteDelegate(String delegateId);
  Future<AdminUserDetailsResponseModel> updateUserStatus(String userId, bool isActive);
  Future<AdminUserDetailsResponseModel> createDelegate({
    required String name,
    required String phone,
    required String email,
    required String password,
    required List<Map<String, dynamic>> addresses,
  });
  Future<AdminCreateCenterResponseModel> createCenter({
    required String ownerName,
    required String phone,
    required String email,
    required String password,
    required String name,
    required String address,
    required String city,
    required List<String> supportedBrands,
    required List<String> supportedDeviceTypes,
    required String? logoPath,
    required Map<String, double> coordinates,
  });
  Future<AdminCreateCenterResponseModel> updateCenterStatus(String centerId, String status);
  Future<AdminDelegateApplicationsResponseModel> getDelegateApplications({required int page, required int limit});
  Future<AdminDelegateApplicationDetailsResponseModel> getDelegateApplicationDetails(String applicationId);
  Future<AdminApproveDelegateResponseModel> approveDelegateApplication(String id);
  Future<AdminRejectDelegateResponseModel> rejectDelegateApplication(String id, String rejectReason);
  Future<AdminPaymentsResponseModel> getAdminPayments({required int page, required int limit});
  Future<AdminReviewPaymentResponseModel> reviewPayment(
    String paymentId, {
    required String status,
    String? rejectionReason,
  });
  Future<AdminPaymentSettingsResponseModel> updatePaymentSettings({
    required String walletOwnerName,
    required Map<String, String> walletNumbers,
    required List<String> activePaymentMethods,
    required String paymentInstructions,
  });
  Future<AdminPaymentSettingsResponseModel> getPaymentSettings();
  Future<AdminFinancialSettingsResponseModel> updateFinancialSettings({
    required String commissionType,
    required double commissionValue,
    required String delegateFeeType,
    required double delegateFeeValue,
    required String currency,
    required bool isActive,
  });
  Future<AdminFinancialSettingsResponseModel> getFinancialSettings();
  Future<CouponResponseModel> createCoupon({
    required String code,
    required num discountValue,
  });
  Future<CouponResponseModel> updateCoupon({
    required String id,
    num? discountValue,
    bool? isActive,
  });
  Future<CouponsListResponseModel> getCoupons();
}

@LazySingleton(as: AdminRemoteDataSource)
class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final ApiManager _apiManager;

  AdminRemoteDataSourceImpl(this._apiManager);

  @override
  Future<OrdersResponseModel> getOrders({required int page, required int limit}) async {
    final response = await _apiManager.getDate(
      Endpoints.adminOrders,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    if (response.data != null) {
      return OrdersResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب الطلبات');
    }
  }

  @override
  Future<OrderDetailsResponseModel> getOrderDetails(String orderId) async {
    final response = await _apiManager.getDate(
      '${Endpoints.adminOrders}/$orderId',
    );

    if (response.data != null) {
      return OrderDetailsResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب تفاصيل الطلب');
    }
  }

  @override
  Future<AdminUsersResponseModel> getUsers({required int page, required int limit}) async {
    final response = await _apiManager.getDate(
      Endpoints.adminUsers,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    if (response.data != null) {
      return AdminUsersResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب المستخدمين');
    }
  }

  @override
  Future<AdminDelegatesResponseModel> getDelegates({required int page, required int limit}) async {
    final response = await _apiManager.getDate(
      Endpoints.adminDelegates,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    if (response.data != null) {
      return AdminDelegatesResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب المندوبين');
    }
  }

  @override
  Future<AdminCentersResponseModel> getCenters({required int page, required int limit}) async {
    final response = await _apiManager.getDate(
      Endpoints.adminCenters,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    if (response.data != null) {
      return AdminCentersResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب مراكز الصيانة');
    }
  }

  @override
  Future<AdminUserDetailsResponseModel> getUserDetails(String userId) async {
    final response = await _apiManager.getDate(
      Endpoints.adminUserDetails + userId,
    );

    if (response.data != null) {
      return AdminUserDetailsResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب تفاصيل المستخدم');
    }
  }

  @override
  Future<AdminCenterDetailsResponseModel> getCenterDetails(String centerId) async {
    final response = await _apiManager.getDate(
      '${Endpoints.adminCenters}/$centerId',
    );

    if (response.data != null) {
      return AdminCenterDetailsResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب تفاصيل مركز الصيانة');
    }
  }

  @override
  Future<AdminUserDetailsResponseModel> deleteUser(String userId) async {
    final response = await _apiManager.Deletedata(
      Endpoints.adminUserDetails + userId,
    );

    if (response.data != null) {
      return AdminUserDetailsResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في حذف المستخدم');
    }
  }

  @override
  Future<AdminUserDetailsResponseModel> deleteDelegate(String delegateId) async {
    final response = await _apiManager.Deletedata(
      '${Endpoints.adminDelegates}/$delegateId',
    );

    if (response.data != null) {
      return AdminUserDetailsResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في حذف المندوب');
    }
  }

  @override
  Future<AdminUserDetailsResponseModel> updateUserStatus(String userId, bool isActive) async {
    final response = await _apiManager.UpdateData(
      '${Endpoints.adminUserDetails}$userId/status',
      body: {'isActive': isActive},
    );

    if (response.data != null) {
      return AdminUserDetailsResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في تعديل حالة المستخدم');
    }
  }

  @override
  Future<AdminUserDetailsResponseModel> createDelegate({
    required String name,
    required String phone,
    required String email,
    required String password,
    required List<Map<String, dynamic>> addresses,
  }) async {
    final response = await _apiManager.PostDate(
      Endpoints.adminDelegates,
      body: {
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
        'addresses': addresses,
      },
    );

    if (response.data != null) {
      return AdminUserDetailsResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في إنشاء المندوب');
    }
  }

  @override
  Future<AdminCreateCenterResponseModel> createCenter({
    required String ownerName,
    required String phone,
    required String email,
    required String password,
    required String name,
    required String address,
    required String city,
    required List<String> supportedBrands,
    required List<String> supportedDeviceTypes,
    required String? logoPath,
    required Map<String, double> coordinates,
  }) async {
    final Map<String, dynamic> fields = {
      'ownerName': ownerName,
      'phone': phone,
      'email': email,
      'password': password,
      'name': name,
      'address': address,
      'city': city,
      'supportedBrands': jsonEncode(supportedBrands),
      'supportedDeviceTypes': jsonEncode(supportedDeviceTypes),
      'coordinates': jsonEncode(coordinates),
    };

    if (logoPath != null && logoPath.isNotEmpty) {
      if (kIsWeb) {
        final bytes = await XFile(logoPath).readAsBytes();
        final fileName = logoPath.split('/').last;
        String webFilename = fileName;
        MediaType mediaType = MediaType('image', 'jpeg');
        if (fileName.contains('.')) {
          final ext = fileName.split('.').last.toLowerCase();
          if (ext == 'png') {
            mediaType = MediaType('image', 'png');
          } else if (ext == 'gif') {
            mediaType = MediaType('image', 'gif');
          } else if (ext == 'webp') {
            mediaType = MediaType('image', 'webp');
          }
        } else {
          webFilename = '$fileName.jpg';
        }
        fields['logo'] = MultipartFile.fromBytes(
          bytes,
          filename: webFilename,
          contentType: mediaType,
        );
      } else {
        final fileName = logoPath.split('/').last;
        fields['logo'] = await MultipartFile.fromFile(
          logoPath,
          filename: fileName,
        );
      }
    }

    final formData = FormData.fromMap(fields);

    final response = await _apiManager.PostFormData(
      Endpoints.adminCenters,
      formData: formData,
    );

    if (response.data != null) {
      return AdminCreateCenterResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في إنشاء مركز الصيانة');
    }
  }

  @override
  Future<AdminCreateCenterResponseModel> updateCenterStatus(String centerId, String status) async {
    final response = await _apiManager.UpdateData(
      '${Endpoints.adminCenters}/$centerId/status',
      body: {'status': status},
    );

    if (response.data != null) {
      return AdminCreateCenterResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في تعديل حالة مركز الصيانة');
    }
  }

  @override
  Future<AdminDelegateApplicationsResponseModel> getDelegateApplications({required int page, required int limit}) async {
    final response = await _apiManager.getDate(
      Endpoints.adminDelegateApplications,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    if (response.data != null) {
      return AdminDelegateApplicationsResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب طلبات تسجيل المندوبين');
    }
  }

  @override
  Future<AdminDelegateApplicationDetailsResponseModel> getDelegateApplicationDetails(String applicationId) async {
    final response = await _apiManager.getDate(
      '${Endpoints.adminDelegateApplications}/$applicationId',
    );

    if (response.data != null) {
      return AdminDelegateApplicationDetailsResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب تفاصيل طلب المندوب');
    }
  }

  @override
  Future<AdminApproveDelegateResponseModel> approveDelegateApplication(String id) async {
    final response = await _apiManager.UpdateData(
      '${Endpoints.adminDelegateApplications}/$id/approve',
      body: {},
    );

    if (response.data != null) {
      return AdminApproveDelegateResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في قبول طلب المندوب');
    }
  }

  @override
  Future<AdminRejectDelegateResponseModel> rejectDelegateApplication(String id, String rejectReason) async {
    final response = await _apiManager.UpdateData(
      '${Endpoints.adminDelegateApplications}/$id/reject',
      body: {'rejectReason': rejectReason},
    );

    if (response.data != null) {
      return AdminRejectDelegateResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في رفض طلب المندوب');
    }
  }

  @override
  Future<AdminPaymentsResponseModel> getAdminPayments({required int page, required int limit}) async {
    final response = await _apiManager.getDate(
      Endpoints.adminPayments,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    if (response.data != null) {
      return AdminPaymentsResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب التحويلات والدفع');
    }
  }

  @override
  Future<AdminReviewPaymentResponseModel> reviewPayment(
    String paymentId, {
    required String status,
    String? rejectionReason,
  }) async {
    final Map<String, dynamic> body = {
      'status': status,
    };
    if (rejectionReason != null) {
      body['rejectionReason'] = rejectionReason;
    }

    final response = await _apiManager.UpdateData(
      '${Endpoints.adminPayments}/$paymentId/review',
      body: body,
    );

    if (response.data != null) {
      return AdminReviewPaymentResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في مراجعة الدفع');
    }
  }

  @override
  Future<AdminPaymentSettingsResponseModel> updatePaymentSettings({
    required String walletOwnerName,
    required Map<String, String> walletNumbers,
    required List<String> activePaymentMethods,
    required String paymentInstructions,
  }) async {
    final response = await _apiManager.UpdateData(
      Endpoints.adminPaymentSettings,
      body: {
        'walletOwnerName': walletOwnerName,
        'walletNumbers': walletNumbers,
        'activePaymentMethods': activePaymentMethods,
        'paymentInstructions': paymentInstructions,
      },
    );

    if (response.data != null) {
      return AdminPaymentSettingsResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في تحديث إعدادات الدفع');
    }
  }

  @override
  Future<AdminPaymentSettingsResponseModel> getPaymentSettings() async {
    final response = await _apiManager.getDate(
      Endpoints.adminPaymentSettings,
    );

    if (response.data != null) {
      return AdminPaymentSettingsResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب إعدادات الدفع');
    }
  }

  @override
  Future<AdminFinancialSettingsResponseModel> updateFinancialSettings({
    required String commissionType,
    required double commissionValue,
    required String delegateFeeType,
    required double delegateFeeValue,
    required String currency,
    required bool isActive,
  }) async {
    final response = await _apiManager.UpdateData(
      Endpoints.adminFinancialSettings,
      body: {
        'commissionType': commissionType,
        'commissionValue': commissionValue,
        'delegateFeeValue': delegateFeeValue,
        'currency': currency,
        'isActive': isActive,
      },
    );

    if (response.data != null) {
      return AdminFinancialSettingsResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في تحديث الإعدادات المالية');
    }
  }

  @override
  Future<AdminFinancialSettingsResponseModel> getFinancialSettings() async {
    final response = await _apiManager.getDate(
      Endpoints.adminFinancialSettings,
    );

    if (response.data != null) {
      return AdminFinancialSettingsResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب الإعدادات المالية');
    }
  }

  @override
  Future<AdminDashboardResponseModel> getAdminDashboard() async {
    final response = await _apiManager.getDate(Endpoints.adminDashboard);
    if (response.data != null) {
      return AdminDashboardResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب لوحة إحصائيات الإدارة');
    }
  }

  @override
  Future<AdminSettlementsResponseModel> getAdminSettlements({
    required int page,
    required int limit,
    String? status,
    String? recipientType,
    String? recipientId,
    String? order,
    String? paymentMethod,
    String? dateFrom,
    String? dateTo,
    String? sort,
  }) async {
    String url = '${Endpoints.adminSettlements}?page=$page&limit=$limit';
    if (status != null && status.isNotEmpty && status != 'all') {
      url += '&status=$status';
    }
    if (recipientType != null && recipientType.isNotEmpty && recipientType != 'all') {
      url += '&recipientType=$recipientType';
    }
    if (recipientId != null && recipientId.isNotEmpty) {
      url += '&recipientId=$recipientId';
    }
    if (order != null && order.isNotEmpty) {
      url += '&order=$order';
    }
    if (paymentMethod != null && paymentMethod.isNotEmpty && paymentMethod != 'all') {
      url += '&paymentMethod=$paymentMethod';
    }
    if (dateFrom != null && dateFrom.isNotEmpty) {
      url += '&dateFrom=$dateFrom';
    }
    if (dateTo != null && dateTo.isNotEmpty) {
      url += '&dateTo=$dateTo';
    }
    if (sort != null && sort.isNotEmpty) {
      url += '&sort=$sort';
    }
    final response = await _apiManager.getDate(url);
    if (response.data != null) {
      return AdminSettlementsResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب تسويات النظام');
    }
  }

  @override
  Future<AdminSettlementsSummaryResponseModel> getAdminSettlementsSummary({
    required int page,
    required int limit,
    String? recipientType,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    String url = '${Endpoints.adminSettlementsSummary}?page=$page&limit=$limit';
    if (recipientType != null && recipientType.isNotEmpty && recipientType != 'all') {
      url += '&recipientType=$recipientType';
    }
    if (search != null && search.isNotEmpty) {
      url += '&search=$search';
    }
    if (sortBy != null && sortBy.isNotEmpty) {
      url += '&sortBy=$sortBy';
    }
    if (sortOrder != null && sortOrder.isNotEmpty) {
      url += '&sortOrder=$sortOrder';
    }
    final response = await _apiManager.getDate(url);
    if (response.data != null) {
      return AdminSettlementsSummaryResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب ملخص التسويات المجمع');
    }
  }

  @override
  Future<AdminPaySettlementResponseModel> payAdminSettlement(
    String settlementId, {
    String? paymentMethod,
    String? notes,
  }) async {
    final Map<String, dynamic> body = {};
    if (paymentMethod != null && paymentMethod.isNotEmpty) {
      body['paymentMethod'] = paymentMethod;
    }
    if (notes != null && notes.isNotEmpty) {
      body['notes'] = notes;
    }
    final response = await _apiManager.PatchData(
      Endpoints.payAdminSettlement(settlementId),
      body: body,
    );
    if (response.data != null) {
      return AdminPaySettlementResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في تأكيد دفع التسوية');
    }
  }

  @override
  Future<CouponResponseModel> createCoupon({
    required String code,
    required num discountValue,
  }) async {
    final response = await _apiManager.PostDate(
      Endpoints.adminCoupons,
      body: {
        'code': code,
        'discountValue': discountValue,
      },
    );

    if (response.data != null) {
      return CouponResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في إنشاء الكوبون');
    }
  }

  @override
  Future<CouponResponseModel> updateCoupon({
    required String id,
    num? discountValue,
    bool? isActive,
  }) async {
    final Map<String, dynamic> body = {};
    if (discountValue != null) body['discountValue'] = discountValue;
    if (isActive != null) body['isActive'] = isActive;

    final response = await _apiManager.UpdateData(
      Endpoints.adminUpdateCoupon(id),
      body: body,
    );

    if (response.data != null) {
      return CouponResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في تحديث الكوبون');
    }
  }

  @override
  Future<CouponsListResponseModel> getCoupons() async {
    final response = await _apiManager.getDate(
      Endpoints.adminCoupons,
    );

    if (response.data != null) {
      return CouponsListResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب الكوبونات');
    }
  }

  @override
  Future<AdminSettlementsReportResponseModel> getAdminSettlementsReport() async {
    final response = await _apiManager.getDate(
      Endpoints.adminSettlements,
    );

    if (response.data != null) {
      return AdminSettlementsReportResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب تقرير التسويات');
    }
  }

  @override
  Future<AdminUpdateOrderSettlementResponseModel> updateOrderSettlement({
    required String orderId,
    required String party,
    required bool settled,
  }) async {
    final response = await _apiManager.UpdateData(
      Endpoints.updateOrderSettlement(orderId),
      body: {
        'party': party,
        'settled': settled,
      },
    );

    if (response.data != null) {
      return AdminUpdateOrderSettlementResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في تحديث حالة التسوية');
    }
  }
}

