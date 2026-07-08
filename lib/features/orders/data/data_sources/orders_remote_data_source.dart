import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/api/api_manager.dart';
import '../../../../core/api/endpoints.dart';
import '../models/create_order_response_model.dart';
import '../models/inspection_model.dart';
import '../models/order_details_response_model.dart';
import '../models/order_model.dart';
import '../models/order_tracking_response_model.dart';
import '../models/price_offer_model.dart';

abstract class OrdersRemoteDataSource {
  Future<OrdersResponseModel> getOrders({
    required int page,
    required int limit,
  });

  Future<CreateOrderResponseModel> createOrder({
    required String centerId,
    required String deviceType,
    required String brand,
    required String model,
    required String problemType,
    required String problemDescription,
    required List<String> imagePaths,
    required String address,
    required String city,
  });

  Future<OrderDetailsResponseModel> getOrderDetails(String id);

  Future<OrderTrackingResponseModel> getOrderTracking(String id);

  Future<InspectionResponseModel> getInspectionReport(String orderId);

  Future<PriceOfferResponseModel> getPriceOffer(String orderId);

  Future<OrderDetailsResponseModel> approvePriceOffer(String orderId);
}

@LazySingleton(as: OrdersRemoteDataSource)
class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final ApiManager _apiManager;

  OrdersRemoteDataSourceImpl(this._apiManager);

  @override
  Future<OrdersResponseModel> getOrders({
    required int page,
    required int limit,
  }) async {
    final response = await _apiManager.getDate(
      '${Endpoints.orders}?page=$page&limit=$limit',
    );

    if (response.data != null) {
      return OrdersResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب طلبات الصيانة');
    }
  }

  @override
  Future<CreateOrderResponseModel> createOrder({
    required String centerId,
    required String deviceType,
    required String brand,
    required String model,
    required String problemType,
    required String problemDescription,
    required List<String> imagePaths,
    required String address,
    required String city,
  }) async {
    final formData = FormData();

    // repair center
    formData.fields.add(MapEntry('repairCenter', centerId));

    // device object
    formData.fields.add(
      MapEntry(
        'device',
        jsonEncode({
          'type': deviceType,
          'brand': brand,
          'model': model,
          'problemType': problemType,
          'problemDescription': problemDescription,
        }),
      ),
    );

    // pickupAddress object
    formData.fields.add(
      MapEntry('pickupAddress', jsonEncode({'address': address, 'city': city})),
    );

    // images
    for (final path in imagePaths) {
      formData.files.add(
        MapEntry(
          'images',
          await MultipartFile.fromFile(path, filename: path.split('/').last),
        ),
      );
    }

    final response = await _apiManager.PostFormData(
      Endpoints.orders,
      formData: formData,
    );

    if (response.data != null) {
      return CreateOrderResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في إنشاء طلب الصيانة');
    }
  }

  @override
  Future<OrderDetailsResponseModel> getOrderDetails(String id) async {
    final response = await _apiManager.getDate('${Endpoints.orders}/$id');
    if (response.data != null) {
      return OrderDetailsResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب تفاصيل الطلب');
    }
  }

  @override
  Future<OrderTrackingResponseModel> getOrderTracking(String id) async {
    final response = await _apiManager.getDate('${Endpoints.orders}/$id/tracking');
    if (response.data != null) {
      return OrderTrackingResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في تتبع حالة الطلب');
    }
  }

  @override
  Future<InspectionResponseModel> getInspectionReport(String orderId) async {
    final response = await _apiManager.getDate('${Endpoints.inspection}/$orderId');
    if (response.data != null) {
      return InspectionResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب تقرير الفحص');
    }
  }

  @override
  Future<PriceOfferResponseModel> getPriceOffer(String orderId) async {
    final response = await _apiManager.getDate('${Endpoints.priceOffer}/$orderId');
    if (response.data != null) {
      return PriceOfferResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب عرض السعر');
    }
  }

  @override
  Future<OrderDetailsResponseModel> approvePriceOffer(String orderId) async {
    final response = await _apiManager.UpdateData('${Endpoints.orders}/$orderId/approve-offer');
    if (response.data != null) {
      return OrderDetailsResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في الموافقة على عرض السعر');
    }
  }
}
