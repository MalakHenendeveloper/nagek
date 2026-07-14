import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/admin_paginated_result.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../../domain/entities/admin_center_entity.dart';
import '../../domain/entities/admin_center_details_entity.dart';
import '../../domain/entities/delegate_application_entity.dart';
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
}
