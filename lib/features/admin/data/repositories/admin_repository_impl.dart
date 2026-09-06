import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/admin_paginated_result.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../../domain/entities/admin_center_entity.dart';
import '../../domain/entities/admin_center_details_entity.dart';
import '../../domain/entities/delegate_application_entity.dart';
import '../../domain/entities/admin_payment_entity.dart';
import '../../domain/entities/admin_payment_settings_entity.dart';
import '../../domain/entities/admin_financial_settings_entity.dart';
import '../../domain/entities/admin_dashboard_entity.dart';
import '../../domain/entities/admin_settlement_entity.dart';
import '../../domain/entities/admin_settlements_summary_entity.dart';
import '../../domain/entities/coupon_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../data_sources/admin_remote_data_source.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AdminRepository)
class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _remoteDataSource;

  AdminRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, OrdersResultEntity>> getOrders({required int page, required int limit}) async {
    try {
      final responseModel = await _remoteDataSource.getOrders(page: page, limit: limit);
      if (responseModel.success) {
        final orders = responseModel.orders.map((m) => m.toEntity()).toList();
        final pagination = responseModel.pagination.toEntity();
        return Right(OrdersResultEntity(orders: orders, pagination: pagination));
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء جلب الطلبات'));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderDetails(String orderId) async {
    try {
      final responseModel = await _remoteDataSource.getOrderDetails(orderId);
      if (responseModel.success && responseModel.order != null) {
        return Right(responseModel.order!.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء جلب تفاصيل الطلب'));
    }
  }

  @override
  Future<Either<Failure, AdminUsersResult>> getUsers({required int page, required int limit}) async {
    try {
      final responseModel = await _remoteDataSource.getUsers(page: page, limit: limit);
      if (responseModel.success) {
        return Right(responseModel.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء جلب قائمة المستخدمين'));
    }
  }

  @override
  Future<Either<Failure, AdminDelegatesResult>> getDelegates({required int page, required int limit}) async {
    try {
      final responseModel = await _remoteDataSource.getDelegates(page: page, limit: limit);
      if (responseModel.success) {
        return Right(responseModel.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء جلب قائمة المندوبين'));
    }
  }

  @override
  Future<Either<Failure, AdminCentersResult>> getCenters({required int page, required int limit}) async {
    try {
      final responseModel = await _remoteDataSource.getCenters(page: page, limit: limit);
      if (responseModel.success) {
        return Right(responseModel.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء جلب قائمة مراكز الصيانة'));
    }
  }

  @override
  Future<Either<Failure, AdminUserEntity>> getUserDetails(String userId) async {
    try {
      final responseModel = await _remoteDataSource.getUserDetails(userId);
      if (responseModel.success && responseModel.user != null) {
        return Right(responseModel.user!.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء جلب تفاصيل المستخدم'));
    }
  }

  @override
  Future<Either<Failure, AdminCenterDetailsEntity>> getCenterDetails(String centerId) async {
    try {
      final responseModel = await _remoteDataSource.getCenterDetails(centerId);
      if (responseModel.success && responseModel.center != null) {
        return Right(responseModel.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء جلب تفاصيل مركز الصيانة'));
    }
  }

  @override
  Future<Either<Failure, AdminUserEntity>> deleteUser(String userId) async {
    try {
      final responseModel = await _remoteDataSource.deleteUser(userId);
      if (responseModel.success && responseModel.user != null) {
        return Right(responseModel.user!.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء حذف المستخدم'));
    }
  }

  @override
  Future<Either<Failure, AdminUserEntity>> deleteDelegate(String delegateId) async {
    try {
      final responseModel = await _remoteDataSource.deleteDelegate(delegateId);
      if (responseModel.success && responseModel.user != null) {
        return Right(responseModel.user!.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء حذف المندوب'));
    }
  }

  @override
  Future<Either<Failure, AdminUserEntity>> updateUserStatus(String userId, bool isActive) async {
    try {
      final responseModel = await _remoteDataSource.updateUserStatus(userId, isActive);
      if (responseModel.success && responseModel.user != null) {
        return Right(responseModel.user!.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء تعديل حالة المستخدم'));
    }
  }

  @override
  Future<Either<Failure, AdminUserEntity>> createDelegate({
    required String name,
    required String phone,
    required String email,
    required String password,
    required List<Map<String, dynamic>> addresses,
  }) async {
    try {
      final responseModel = await _remoteDataSource.createDelegate(
        name: name,
        phone: phone,
        email: email,
        password: password,
        addresses: addresses,
      );
      if (responseModel.success && responseModel.user != null) {
        return Right(responseModel.user!.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء إنشاء المندوب'));
    }
  }

  @override
  Future<Either<Failure, AdminCenterEntity>> createCenter({
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
    try {
      final responseModel = await _remoteDataSource.createCenter(
        ownerName: ownerName,
        phone: phone,
        email: email,
        password: password,
        name: name,
        address: address,
        city: city,
        supportedBrands: supportedBrands,
        supportedDeviceTypes: supportedDeviceTypes,
        logoPath: logoPath,
        coordinates: coordinates,
      );
      if (responseModel.success && responseModel.center != null) {
        return Right(responseModel.center!.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء إنشاء مركز الصيانة'));
    }
  }

  @override
  Future<Either<Failure, AdminCenterEntity>> updateCenterStatus(String centerId, String status) async {
    try {
      final responseModel = await _remoteDataSource.updateCenterStatus(centerId, status);
      if (responseModel.success && responseModel.center != null) {
        return Right(responseModel.center!.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء تعديل حالة مركز الصيانة'));
    }
  }

  @override
  Future<Either<Failure, AdminDelegateApplicationsResult>> getDelegateApplications({required int page, required int limit}) async {
    try {
      final responseModel = await _remoteDataSource.getDelegateApplications(page: page, limit: limit);
      if (responseModel.success) {
        return Right(responseModel.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء جلب طلبات تسجيل المندوبين'));
    }
  }

  @override
  Future<Either<Failure, DelegateApplicationEntity>> getDelegateApplicationDetails(String applicationId) async {
    try {
      final responseModel = await _remoteDataSource.getDelegateApplicationDetails(applicationId);
      if (responseModel.success && responseModel.application != null) {
        return Right(responseModel.application!.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء جلب تفاصيل طلب المندوب'));
    }
  }

  @override
  Future<Either<Failure, void>> approveDelegateApplication(String id) async {
    try {
      final responseModel = await _remoteDataSource.approveDelegateApplication(id);
      if (responseModel.success) {
        return const Right(null);
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء قبول طلب المندوب'));
    }
  }

  @override
  Future<Either<Failure, void>> rejectDelegateApplication(String id, String rejectReason) async {
    try {
      final responseModel = await _remoteDataSource.rejectDelegateApplication(id, rejectReason);
      if (responseModel.success) {
        return const Right(null);
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء رفض طلب المندوب'));
    }
  }

  @override
  Future<Either<Failure, AdminPaymentsResult>> getAdminPayments({required int page, required int limit}) async {
    try {
      final responseModel = await _remoteDataSource.getAdminPayments(page: page, limit: limit);
      if (responseModel.success) {
        return Right(responseModel.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء جلب التحويلات والدفع'));
    }
  }

  @override
  Future<Either<Failure, void>> reviewPayment(
    String paymentId, {
    required String status,
    String? rejectionReason,
  }) async {
    try {
      final responseModel = await _remoteDataSource.reviewPayment(
        paymentId,
        status: status,
        rejectionReason: rejectionReason,
      );
      if (responseModel.success) {
        return const Right(null);
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء مراجعة عملية الدفع'));
    }
  }

  @override
  Future<Either<Failure, AdminPaymentSettingsEntity>> updatePaymentSettings({
    required String walletOwnerName,
    required Map<String, String> walletNumbers,
    required List<String> activePaymentMethods,
    required String paymentInstructions,
  }) async {
    try {
      final responseModel = await _remoteDataSource.updatePaymentSettings(
        walletOwnerName: walletOwnerName,
        walletNumbers: walletNumbers,
        activePaymentMethods: activePaymentMethods,
        paymentInstructions: paymentInstructions,
      );
      if (responseModel.success && responseModel.data != null) {
        return Right(responseModel.data!.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء تحديث إعدادات الدفع'));
    }
  }

  @override
  Future<Either<Failure, AdminPaymentSettingsEntity>> getPaymentSettings() async {
    try {
      final responseModel = await _remoteDataSource.getPaymentSettings();
      if (responseModel.success && responseModel.data != null) {
        return Right(responseModel.data!.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء جلب إعدادات الدفع'));
    }
  }

  @override
  Future<Either<Failure, AdminFinancialSettingsEntity>> updateFinancialSettings({
    required String commissionType,
    required double commissionValue,
    required String delegateFeeType,
    required double delegateFeeValue,
    required String currency,
    required bool isActive,
  }) async {
    try {
      final responseModel = await _remoteDataSource.updateFinancialSettings(
        commissionType: commissionType,
        commissionValue: commissionValue,
        delegateFeeType: delegateFeeType,
        delegateFeeValue: delegateFeeValue,
        currency: currency,
        isActive: isActive,
      );
      if (responseModel.success && responseModel.data != null) {
        return Right(responseModel.data!.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء تحديث الإعدادات المالية'));
    }
  }

  @override
  Future<Either<Failure, AdminFinancialSettingsEntity>> getFinancialSettings() async {
    try {
      final responseModel = await _remoteDataSource.getFinancialSettings();
      if (responseModel.success && responseModel.data != null) {
        return Right(responseModel.data!.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء جلب الإعدادات المالية'));
    }
  }

  @override
  Future<Either<Failure, AdminDashboardEntity>> getAdminDashboard() async {
    try {
      final responseModel = await _remoteDataSource.getAdminDashboard();
      if (responseModel.success) {
        return Right(responseModel.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء جلب لوحة إحصائيات الإدارة'));
    }
  }

  @override
  Future<Either<Failure, AdminSettlementsResultEntity>> getAdminSettlements({
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
    try {
      final responseModel = await _remoteDataSource.getAdminSettlements(
        page: page,
        limit: limit,
        status: status,
        recipientType: recipientType,
        recipientId: recipientId,
        order: order,
        paymentMethod: paymentMethod,
        dateFrom: dateFrom,
        dateTo: dateTo,
        sort: sort,
      );
      if (responseModel.success) {
        return Right(responseModel.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء جلب تسويات النظام'));
    }
  }

  @override
  Future<Either<Failure, AdminSettlementsSummaryResultEntity>> getAdminSettlementsSummary({
    required int page,
    required int limit,
    String? recipientType,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final responseModel = await _remoteDataSource.getAdminSettlementsSummary(
        page: page,
        limit: limit,
        recipientType: recipientType,
        search: search,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
      if (responseModel.success) {
        return Right(responseModel.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء جلب ملخص التسويات المجمع'));
    }
  }

  @override
  Future<Either<Failure, AdminSettlementEntity>> payAdminSettlement(
    String settlementId, {
    String? paymentMethod,
    String? notes,
  }) async {
    try {
      final responseModel = await _remoteDataSource.payAdminSettlement(
        settlementId,
        paymentMethod: paymentMethod,
        notes: notes,
      );
      if (responseModel.success && responseModel.settlement != null) {
        return Right(responseModel.settlement!.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء تأكيد دفع التسوية'));
    }
  }

  @override
  Future<Either<Failure, CouponEntity>> createCoupon({
    required String code,
    required num discountValue,
  }) async {
    try {
      final responseModel = await _remoteDataSource.createCoupon(
        code: code,
        discountValue: discountValue,
      );
      if (responseModel.success && responseModel.coupon != null) {
        return Right(responseModel.coupon!.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException') 
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : e.toString()));
    }
  }

  @override
  Future<Either<Failure, CouponEntity>> updateCoupon({
    required String id,
    num? discountValue,
    bool? isActive,
  }) async {
    try {
      final responseModel = await _remoteDataSource.updateCoupon(
        id: id,
        discountValue: discountValue,
        isActive: isActive,
      );
      if (responseModel.success && responseModel.coupon != null) {
        return Right(responseModel.coupon!.toEntity());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء تحديث الكوبون'));
    }
  }

  @override
  Future<Either<Failure, List<CouponEntity>>> getCoupons() async {
    try {
      final responseModel = await _remoteDataSource.getCoupons();
      if (responseModel.success) {
        return Right(responseModel.coupons.map((e) => e.toEntity()).toList());
      } else {
        return Left(ServerFailure(responseModel.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().contains('SocketException')
          ? 'تعذر الاتصال بالإنترنت، يرجى التحقق من الشبكة'
          : 'حدث خطأ أثناء جلب الكوبونات'));
    }
  }
}

