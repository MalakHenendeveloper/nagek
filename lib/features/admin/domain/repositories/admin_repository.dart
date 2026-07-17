import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/admin_paginated_result.dart';
import '../entities/admin_user_entity.dart';
import '../entities/admin_center_entity.dart';
import '../entities/admin_center_details_entity.dart';
import '../entities/delegate_application_entity.dart';
import '../entities/admin_payment_entity.dart';
import '../../../orders/domain/entities/order_entity.dart';

abstract class AdminRepository {
  Future<Either<Failure, OrdersResultEntity>> getOrders({required int page, required int limit});
  Future<Either<Failure, OrderEntity>> getOrderDetails(String orderId);
  Future<Either<Failure, AdminUsersResult>> getUsers({required int page, required int limit});
  Future<Either<Failure, AdminDelegatesResult>> getDelegates({required int page, required int limit});
  Future<Either<Failure, AdminCentersResult>> getCenters({required int page, required int limit});
  Future<Either<Failure, AdminUserEntity>> getUserDetails(String userId);
  Future<Either<Failure, AdminCenterDetailsEntity>> getCenterDetails(String centerId);
  Future<Either<Failure, AdminUserEntity>> deleteUser(String userId);
  Future<Either<Failure, AdminUserEntity>> deleteDelegate(String delegateId);
  Future<Either<Failure, AdminUserEntity>> updateUserStatus(String userId, bool isActive);
  Future<Either<Failure, AdminUserEntity>> createDelegate({
    required String name,
    required String phone,
    required String email,
    required String password,
    required List<Map<String, dynamic>> addresses,
  });
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
  });
  Future<Either<Failure, AdminCenterEntity>> updateCenterStatus(String centerId, String status);
  Future<Either<Failure, AdminDelegateApplicationsResult>> getDelegateApplications({required int page, required int limit});
  Future<Either<Failure, DelegateApplicationEntity>> getDelegateApplicationDetails(String applicationId);
  Future<Either<Failure, void>> approveDelegateApplication(String id);
  Future<Either<Failure, void>> rejectDelegateApplication(String id, String rejectReason);
  Future<Either<Failure, AdminPaymentsResult>> getAdminPayments({required int page, required int limit});
  Future<Either<Failure, void>> reviewPayment(
    String paymentId, {
    required String status,
    String? rejectionReason,
  });
}
