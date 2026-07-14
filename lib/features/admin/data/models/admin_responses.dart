import 'admin_user_model.dart';
import 'admin_center_model.dart';
import '../../../../features/centers/data/models/center_model.dart'; // for PaginationModel
import '../../../../features/centers/data/models/service_model.dart';
import '../../domain/entities/admin_paginated_result.dart';
import '../../domain/entities/admin_center_details_entity.dart';

class AdminUsersResponseModel {
  final bool success;
  final String message;
  final List<AdminUserModel> users;
  final PaginationModel pagination;

  AdminUsersResponseModel({
    required this.success,
    required this.message,
    required this.users,
    required this.pagination,
  });

  factory AdminUsersResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final usersList = data['users'] as List<dynamic>? ?? [];

    return AdminUsersResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      users: usersList.map((e) => AdminUserModel.fromJson(e)).toList(),
      pagination: PaginationModel.fromJson(json['pagination'] ?? {}),
    );
  }

  AdminUsersResult toEntity() {
    return AdminUsersResult(
      users: users.map((e) => e.toEntity()).toList(),
      pagination: pagination.toEntity(),
    );
  }
}

class AdminDelegatesResponseModel {
  final bool success;
  final String message;
  final List<AdminUserModel> delegates;
  final PaginationModel pagination;

  AdminDelegatesResponseModel({
    required this.success,
    required this.message,
    required this.delegates,
    required this.pagination,
  });

  factory AdminDelegatesResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final delegatesList = data['delegates'] as List<dynamic>? ?? [];

    return AdminDelegatesResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      delegates: delegatesList.map((e) => AdminUserModel.fromJson(e)).toList(),
      pagination: PaginationModel.fromJson(json['pagination'] ?? {}),
    );
  }

  AdminDelegatesResult toEntity() {
    return AdminDelegatesResult(
      delegates: delegates.map((e) => e.toEntity()).toList(),
      pagination: pagination.toEntity(),
    );
  }
}

class AdminCentersResponseModel {
  final bool success;
  final String message;
  final List<AdminCenterModel> centers;
  final PaginationModel pagination;

  AdminCentersResponseModel({
    required this.success,
    required this.message,
    required this.centers,
    required this.pagination,
  });

  factory AdminCentersResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final centersList = data['centers'] as List<dynamic>? ?? [];

    return AdminCentersResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      centers: centersList.map((e) => AdminCenterModel.fromJson(e)).toList(),
      pagination: PaginationModel.fromJson(json['pagination'] ?? {}),
    );
  }

  AdminCentersResult toEntity() {
    return AdminCentersResult(
      centers: centers.map((e) => e.toEntity()).toList(),
      pagination: pagination.toEntity(),
    );
  }
}

class AdminUserDetailsResponseModel {
  final bool success;
  final String message;
  final AdminUserModel? user;

  AdminUserDetailsResponseModel({
    required this.success,
    required this.message,
    this.user,
  });

  factory AdminUserDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final userMap = (data['user'] ?? data['delegate']) as Map<String, dynamic>?;

    return AdminUserDetailsResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      user: userMap != null ? AdminUserModel.fromJson(userMap) : null,
    );
  }
}

class AdminCreateCenterResponseModel {
  final bool success;
  final String message;
  final AdminCenterModel? center;

  AdminCreateCenterResponseModel({
    required this.success,
    required this.message,
    this.center,
  });

  factory AdminCreateCenterResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final centerJson = data['center'] as Map<String, dynamic>?;
    final userJson = data['user'] as Map<String, dynamic>?;

    AdminCenterModel? parsedCenter;
    if (centerJson != null) {
      final ownerMap = {
        '_id': userJson?['id'] ?? userJson?['_id'] ?? centerJson['owner'] ?? '',
        'name': userJson?['name'] ?? '',
        'phone': centerJson['phone'] ?? '',
        'email': centerJson['email'] ?? '',
      };
      
      final modifiedCenterJson = Map<String, dynamic>.from(centerJson);
      modifiedCenterJson['owner'] = ownerMap;

      parsedCenter = AdminCenterModel.fromJson(modifiedCenterJson);
    }

    return AdminCreateCenterResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      center: parsedCenter,
    );
  }
}

class AdminCenterStatisticsModel {
  final int ordersCount;
  final int activeOrders;
  final int completedOrders;

  AdminCenterStatisticsModel({
    required this.ordersCount,
    required this.activeOrders,
    required this.completedOrders,
  });

  factory AdminCenterStatisticsModel.fromJson(Map<String, dynamic> json) {
    return AdminCenterStatisticsModel(
      ordersCount: json['ordersCount'] ?? 0,
      activeOrders: json['activeOrders'] ?? 0,
      completedOrders: json['completedOrders'] ?? 0,
    );
  }

  AdminCenterStatisticsEntity toEntity() {
    return AdminCenterStatisticsEntity(
      ordersCount: ordersCount,
      activeOrders: activeOrders,
      completedOrders: completedOrders,
    );
  }
}

class AdminCenterDetailsResponseModel {
  final bool success;
  final String message;
  final AdminCenterModel? center;
  final List<ServiceModel> services;
  final AdminCenterStatisticsModel? statistics;

  AdminCenterDetailsResponseModel({
    required this.success,
    required this.message,
    this.center,
    required this.services,
    this.statistics,
  });

  factory AdminCenterDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final centerJson = data['center'] as Map<String, dynamic>?;
    final servicesList = data['services'] as List<dynamic>? ?? [];
    final statsJson = data['statistics'] as Map<String, dynamic>?;

    return AdminCenterDetailsResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      center: centerJson != null ? AdminCenterModel.fromJson(centerJson) : null,
      services: servicesList.map((e) => ServiceModel.fromJson(e)).toList(),
      statistics: statsJson != null ? AdminCenterStatisticsModel.fromJson(statsJson) : null,
    );
  }

  AdminCenterDetailsEntity toEntity() {
    return AdminCenterDetailsEntity(
      center: center!.toEntity(),
      services: services.map((e) => e.toEntity()).toList(),
      statistics: statistics?.toEntity() ?? AdminCenterStatisticsEntity(ordersCount: 0, activeOrders: 0, completedOrders: 0),
    );
  }
}

