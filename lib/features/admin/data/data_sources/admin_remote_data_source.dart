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
import 'package:injectable/injectable.dart';

abstract class AdminRemoteDataSource {
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
}
