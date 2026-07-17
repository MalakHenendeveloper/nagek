import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:http_parser/http_parser.dart' show MediaType;

import '../../../../core/api/api_manager.dart';
import '../../../../core/api/endpoints.dart';
import '../models/create_order_response_model.dart';
import '../models/inspection_model.dart';
import '../models/order_details_response_model.dart';
import '../models/order_model.dart';
import '../models/order_tracking_response_model.dart';
import '../models/price_offer_model.dart';
import '../models/available_pickup_orders_response_model.dart';
import '../models/pickup_photos_response_model.dart';
import '../models/order_payment_response_model.dart';
import '../models/payment_proof_response_model.dart';

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

  Future<OrderPaymentResponseModel> getOrderPaymentDetails(String orderId);

  Future<PaymentProofResponseModel> submitPaymentProof({
    required String orderId,
    required String senderWalletNumber,
  });

  Future<AvailablePickupOrdersResponseModel> getAvailablePickupOrders();

  Future<AvailablePickupOrdersResponseModel> getAvailableDeliveryOrders();

  Future<AvailablePickupOrdersResponseModel> getDelegateOrders();

  Future<OrderDetailsResponseModel> acceptPickup(String orderId);

  Future<PickupPhotosResponseModel> uploadPickupPhotos(
    String orderId,
    List<String> imagePaths,
  );

  Future<OrderDetailsResponseModel> confirmPickup(String orderId);

  Future<OrderDetailsResponseModel> confirmDropCenter(
    String orderId,
    List<String> imagePaths,
  );
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
          await _getMultipartFile(path),
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
    final response = await _apiManager.getDate(
      '${Endpoints.orders}/$id/tracking',
    );
    if (response.data != null) {
      return OrderTrackingResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في تتبع حالة الطلب');
    }
  }

  @override
  Future<InspectionResponseModel> getInspectionReport(String orderId) async {
    final response = await _apiManager.getDate(
      '${Endpoints.inspection}/$orderId',
    );
    if (response.data != null) {
      return InspectionResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب تقرير الفحص');
    }
  }

  @override
  Future<PriceOfferResponseModel> getPriceOffer(String orderId) async {
    final response = await _apiManager.getDate(
      '${Endpoints.priceOffer}/$orderId',
    );
    if (response.data != null) {
      return PriceOfferResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب عرض السعر');
    }
  }

  @override
  Future<OrderDetailsResponseModel> approvePriceOffer(String orderId) async {
    final response = await _apiManager.UpdateData(
      '${Endpoints.orders}/$orderId/approve-offer',
    );
    if (response.data != null) {
      return OrderDetailsResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في الموافقة على عرض السعر');
    }
  }

  @override
  Future<OrderPaymentResponseModel> getOrderPaymentDetails(String orderId) async {
    final response = await _apiManager.getDate(
      '${Endpoints.orderPayment}$orderId/payment',
    );
    if (response.data != null) {
      return OrderPaymentResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب تفاصيل دفع الطلب');
    }
  }

  @override
  Future<PaymentProofResponseModel> submitPaymentProof({
    required String orderId,
    required String senderWalletNumber,
  }) async {
    final response = await _apiManager.PostDate(
      '${Endpoints.orderPayment}$orderId/payment',
      body: {
        'senderWalletNumber': senderWalletNumber,
      },
    );

    if (response.data != null) {
      return PaymentProofResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في إرسال إثبات الدفع');
    }
  }

  @override
  Future<AvailablePickupOrdersResponseModel> getAvailablePickupOrders() async {
    final response = await _apiManager.getDate(Endpoints.availablePickupOrders);
    if (response.data != null) {
      return AvailablePickupOrdersResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب الطلبات المتاحة للاستلام');
    }
  }

  @override
  Future<AvailablePickupOrdersResponseModel> getAvailableDeliveryOrders() async {
    final response = await _apiManager.getDate(Endpoints.availableDeliveryOrders);
    if (response.data != null) {
      return AvailablePickupOrdersResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب الطلبات المتاحة للتوصيل');
    }
  }

  @override
  Future<OrderDetailsResponseModel> acceptPickup(String orderId) async {
    final response = await _apiManager.UpdateData(
      '${Endpoints.delegateOrders}/$orderId/accept-pickup',
    );
    if (response.data != null) {
      return OrderDetailsResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في قبول مهمة التوصيل');
    }
  }

  @override
  Future<PickupPhotosResponseModel> uploadPickupPhotos(
    String orderId,
    List<String> imagePaths,
  ) async {
    final formData = FormData();

    for (final path in imagePaths) {
      formData.files.add(
        MapEntry(
          'photos',
          await _getMultipartFile(path),
        ),
      );
    }

    final response = await _apiManager.PostFormData(
      '${Endpoints.delegateTasks}/$orderId/pickup-photos',
      formData: formData,
    );

    if (response.data != null) {
      return PickupPhotosResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في رفع صور الاستلام');
    }
  }

  @override
  Future<OrderDetailsResponseModel> confirmPickup(String orderId) async {
    final response = await _apiManager.UpdateData(
      '${Endpoints.delegateTasks}/$orderId/confirm-pickup',
    );
    if (response.data != null) {
      return OrderDetailsResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في تأكيد استلام الجهاز');
    }
  }

  @override
  Future<OrderDetailsResponseModel> confirmDropCenter(
    String orderId,
    List<String> imagePaths,
  ) async {
    final formData = FormData();

    for (final path in imagePaths) {
      formData.files.add(
        MapEntry(
          'photos',
          await _getMultipartFile(path),
        ),
      );
    }

    final response = await _apiManager.PutFormData(
      '${Endpoints.delegateTasks}/$orderId/confirm-drop-center',
      formData: formData,
    );

    if (response.data != null) {
      return OrderDetailsResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في تأكيد تسليم الجهاز للمركز');
    }
  }

  @override
  Future<AvailablePickupOrdersResponseModel> getDelegateOrders() async {
    final response = await _apiManager.getDate(Endpoints.delegateTasks);
    if (response.data != null) {
      return AvailablePickupOrdersResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب طلبات المندوب');
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
}
