import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:http_parser/http_parser.dart' show MediaType;
import '../../../../core/api/api_manager.dart';
import '../../../../core/api/endpoints.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../orders/data/models/inspection_model.dart';
import '../models/center_model.dart';
import '../models/service_model.dart';
import '../models/center_order_details_response_model.dart';
import '../models/price_offer_response_model.dart';

import '../models/center_details_response.dart';
import '../models/center_dashboard_response_model.dart';
import '../models/add_center_service_response_model.dart';
import '../models/center_service_details_response_model.dart';
import '../models/update_center_profile_response_model.dart';

import 'package:injectable/injectable.dart';

abstract class CentersRemoteDataSource {
  Future<UpdateCenterProfileResponseModel> updateCenterProfile({
    required String name,
    required String phone,
    required String email,
    required String address,
    String? logoPath,
  });

  Future<CenterServicesResponseModel> getMyCenterServices();

  Future<CenterServiceDetailsResponseModel> getCenterServiceDetails(String serviceId);

  Future<CenterServiceDetailsResponseModel> updateCenterService({
    required String serviceId,
    required String serviceName,
    required String description,
    required double price,
    required String estimatedTime,
    required bool isAvailable,
  });

  Future<AddCenterServiceResponseModel> addCenterService({
    required String serviceName,
    required String description,
    required double price,
    required String estimatedTime,
    bool isAvailable = true,
  });
  Future<CenterDashboardResponseModel> getCenterDashboard();
  Future<CentersResponseModel> getCenters({
    required int page,
    required int limit,
  });

  Future<CenterDetailsResponseModel> getCenterDetails(String id);

  Future<CenterServicesResponseModel> getCenterServices(String centerId);

  Future<OrdersResponseModel> getCenterDashboardOrders({
    required int page,
    required int limit,
  });

  Future<CenterOrderDetailsResponseModel> getCenterDashboardOrderDetails(
    String orderId,
  );

  Future<InspectionResponseModel> submitInspectionReport({
    required String orderId,
    required String technician,
    required String notes,
    required List<Map<String, String>> findings,
    required List<String> imagePaths,
  });

  Future<PriceOfferResponseModel> submitPriceOffer({
    required String orderId,
    required double totalCost,
    required String notes,
  });

  Future<bool> updateOrderStatus({
    required String orderId,
    required String status,
    required String note,
  });
}

@LazySingleton(as: CentersRemoteDataSource)
class CentersRemoteDataSourceImpl implements CentersRemoteDataSource {
  final ApiManager _apiManager;

  CentersRemoteDataSourceImpl(this._apiManager);

  @override
  Future<CentersResponseModel> getCenters({
    required int page,
    required int limit,
  }) async {
    final response = await _apiManager.getDate(
      '${Endpoints.centers}?page=$page&limit=$limit',
    );

    if (response.data != null) {
      return CentersResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب مراكز الصيانة');
    }
  }

  @override
  Future<CenterDetailsResponseModel> getCenterDetails(String id) async {
    final response = await _apiManager.getDate('${Endpoints.centerDetails}$id');

    if (response.data != null) {
      return CenterDetailsResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب تفاصيل المركز');
    }
  }

  @override
  Future<CenterServicesResponseModel> getCenterServices(String centerId) async {
    final response = await _apiManager.getDate(
      '${Endpoints.centerDetailsServices}$centerId/services',
    );

    if (response.data != null) {
      return CenterServicesResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب خدمات المركز');
    }
  }

  @override
  Future<OrdersResponseModel> getCenterDashboardOrders({
    required int page,
    required int limit,
  }) async {
    final response = await _apiManager.getDate(
      '${Endpoints.centerDashboardOrders}?page=$page&limit=$limit',
    );

    if (response.data != null) {
      return OrdersResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب طلبات مركز الصيانة');
    }
  }

  @override
  Future<CenterOrderDetailsResponseModel> getCenterDashboardOrderDetails(
    String orderId,
  ) async {
    final response = await _apiManager.getDate(
      '${Endpoints.centerDashboardOrderDetails}$orderId',
    );

    if (response.data != null) {
      return CenterOrderDetailsResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب تفاصيل طلب الصيانة للمركز');
    }
  }

  @override
  Future<InspectionResponseModel> submitInspectionReport({
    required String orderId,
    required String technician,
    required String notes,
    required List<Map<String, String>> findings,
    required List<String> imagePaths,
  }) async {
    final formData = FormData();
    formData.fields.add(MapEntry('technician', technician));
    formData.fields.add(MapEntry('notes', notes));
    formData.fields.add(MapEntry('findings', jsonEncode(findings)));

    for (final path in imagePaths) {
      formData.files.add(MapEntry('images', await _getMultipartFile(path)));
    }

    final response = await _apiManager.PostFormData(
      '${Endpoints.centerDashboardInspection}$orderId/inspection',
      formData: formData,
    );

    if (response.data != null) {
      return InspectionResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في تسجيل نتيجة الفحص');
    }
  }

  Future<MultipartFile> _getMultipartFile(String path) async {
    if (kIsWeb) {
      final bytes = await XFile(path).readAsBytes();
      final filename = path.split('/').last;
      String webFilename = filename;
      MediaType mediaType = MediaType('image', 'jpeg');

      if (filename.contains('.')) {
        final ext = filename.split('.').last.toLowerCase();
        if (ext == 'png') {
          mediaType = MediaType('image', 'png');
        } else if (ext == 'gif') {
          mediaType = MediaType('image', 'gif');
        } else if (ext == 'webp') {
          mediaType = MediaType('image', 'webp');
        }
      } else {
        webFilename = '$filename.jpg';
      }

      return MultipartFile.fromBytes(
        bytes,
        filename: webFilename,
        contentType: mediaType,
      );
    } else {
      return await MultipartFile.fromFile(path, filename: path.split('/').last);
    }
  }

  @override
  Future<PriceOfferResponseModel> submitPriceOffer({
    required String orderId,
    required double totalCost,
    required String notes,
  }) async {
    final response = await _apiManager.PostDate(
      '${Endpoints.centerDashboardPriceOffer}$orderId/price-offer',
      body: {
        'totalCost': totalCost,
        'notes': notes,
      },
    );

    if (response.data != null) {
      return PriceOfferResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في إرسال عرض السعر');
    }
  }

  @override
  Future<bool> updateOrderStatus({
    required String orderId,
    required String status,
    required String note,
  }) async {
    final response = await _apiManager.UpdateData(
      '${Endpoints.centerDashboardOrders}/$orderId/status',
      body: {
        'status': status,
        'note': note,
      },
    );

    if (response.data != null && response.data['success'] == true) {
      return true;
    } else {
      final msg = response.data?['message'] ?? 'فشل في تحديث حالة الطلب';
      throw Exception(msg);
    }
  }

  @override
  Future<CenterDashboardResponseModel> getCenterDashboard() async {
    final response = await _apiManager.getDate(Endpoints.centerDashboard);
    if (response.data != null) {
      return CenterDashboardResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب لوحة إحصائيات مركز الصيانة');
    }
  }

  @override
  Future<AddCenterServiceResponseModel> addCenterService({
    required String serviceName,
    required String description,
    required double price,
    required String estimatedTime,
    bool isAvailable = true,
  }) async {
    final response = await _apiManager.PostDate(
      Endpoints.centerServices,
      body: {
        'serviceName': serviceName,
        'description': description,
        'price': price,
        'estimatedTime': estimatedTime,
        'isAvailable': isAvailable,
      },
    );
    if (response.data != null) {
      return AddCenterServiceResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في إضافة الخدمة');
    }
  }

  @override
  Future<CenterServicesResponseModel> getMyCenterServices() async {
    final response = await _apiManager.getDate(Endpoints.centerServices);
    if (response.data != null) {
      return CenterServicesResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب خدمات مركز الصيانة');
    }
  }

  @override
  Future<CenterServiceDetailsResponseModel> getCenterServiceDetails(String serviceId) async {
    final response = await _apiManager.getDate(
      Endpoints.centerServiceDetails(serviceId),
    );
    if (response.data != null) {
      return CenterServiceDetailsResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب تفاصيل الخدمة');
    }
  }

  @override
  Future<CenterServiceDetailsResponseModel> updateCenterService({
    required String serviceId,
    required String serviceName,
    required String description,
    required double price,
    required String estimatedTime,
    required bool isAvailable,
  }) async {
    final response = await _apiManager.UpdateData(
      Endpoints.centerServiceDetails(serviceId),
      body: {
        'serviceName': serviceName,
        'description': description,
        'price': price,
        'estimatedTime': estimatedTime,
        'isAvailable': isAvailable,
      },
    );
    if (response.data != null) {
      return CenterServiceDetailsResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في تحديث الخدمة');
    }
  }

  @override
  Future<UpdateCenterProfileResponseModel> updateCenterProfile({
    required String name,
    required String phone,
    required String email,
    required String address,
    String? logoPath,
  }) async {
    final formData = FormData();
    formData.fields.add(MapEntry('name', name));
    formData.fields.add(MapEntry('phone', phone));
    formData.fields.add(MapEntry('email', email));
    formData.fields.add(MapEntry('address', address));

    if (logoPath != null && logoPath.isNotEmpty) {
      formData.files.add(MapEntry('logo', await _getMultipartFile(logoPath)));
    }

    final response = await _apiManager.PutFormData(
      Endpoints.centerDashboardProfile,
      formData: formData,
    );

    if (response.data != null) {
      return UpdateCenterProfileResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في تحديث ملف مركز الصيانة');
    }
  }
}
