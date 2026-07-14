import '../../domain/entities/delegate_application_entity.dart';
import '../../domain/entities/admin_paginated_result.dart';
import '../../../../features/centers/data/models/center_model.dart'; // for PaginationModel

class DelegateApplicationModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String nationalIdFrontUrl;
  final String nationalIdBackUrl;
  final String drivingLicenseUrl;
  final String motorcycleLicenseUrl;
  final String status;
  final String? rejectReason;
  final String createdAt;
  final String updatedAt;

  DelegateApplicationModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.nationalIdFrontUrl,
    required this.nationalIdBackUrl,
    required this.drivingLicenseUrl,
    required this.motorcycleLicenseUrl,
    required this.status,
    this.rejectReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DelegateApplicationModel.fromJson(Map<String, dynamic> json) {
    final front = json['nationalIdFront'] ?? {};
    final back = json['nationalIdBack'] ?? {};
    final driving = json['drivingLicense'] ?? {};
    final motor = json['motorcycleLicense'] ?? {};

    return DelegateApplicationModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      nationalIdFrontUrl: front['url'] ?? '',
      nationalIdBackUrl: back['url'] ?? '',
      drivingLicenseUrl: driving['url'] ?? '',
      motorcycleLicenseUrl: motor['url'] ?? '',
      status: json['status'] ?? 'pending',
      rejectReason: json['rejectReason'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  DelegateApplicationEntity toEntity() {
    return DelegateApplicationEntity(
      id: id,
      name: name,
      phone: phone,
      email: email,
      nationalIdFrontUrl: nationalIdFrontUrl,
      nationalIdBackUrl: nationalIdBackUrl,
      drivingLicenseUrl: drivingLicenseUrl,
      motorcycleLicenseUrl: motorcycleLicenseUrl,
      status: status,
      rejectReason: rejectReason,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class AdminDelegateApplicationsResponseModel {
  final bool success;
  final String message;
  final List<DelegateApplicationModel> applications;
  final PaginationModel pagination;

  AdminDelegateApplicationsResponseModel({
    required this.success,
    required this.message,
    required this.applications,
    required this.pagination,
  });

  factory AdminDelegateApplicationsResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final appsList = data['applications'] as List<dynamic>? ?? [];

    return AdminDelegateApplicationsResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      applications: appsList.map((e) => DelegateApplicationModel.fromJson(e)).toList(),
      pagination: PaginationModel.fromJson(json['pagination'] ?? {}),
    );
  }

  AdminDelegateApplicationsResult toEntity() {
    return AdminDelegateApplicationsResult(
      applications: applications.map((e) => e.toEntity()).toList(),
      pagination: pagination.toEntity(),
    );
  }
}

class AdminDelegateApplicationDetailsResponseModel {
  final bool success;
  final String message;
  final DelegateApplicationModel? application;

  AdminDelegateApplicationDetailsResponseModel({
    required this.success,
    required this.message,
    this.application,
  });

  factory AdminDelegateApplicationDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final appJson = data['application'] as Map<String, dynamic>?;

    return AdminDelegateApplicationDetailsResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      application: appJson != null ? DelegateApplicationModel.fromJson(appJson) : null,
    );
  }
}

class AdminApproveDelegateResponseModel {
  final bool success;
  final String message;

  AdminApproveDelegateResponseModel({
    required this.success,
    required this.message,
  });

  factory AdminApproveDelegateResponseModel.fromJson(Map<String, dynamic> json) {
    return AdminApproveDelegateResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

class AdminRejectDelegateResponseModel {
  final bool success;
  final String message;

  AdminRejectDelegateResponseModel({
    required this.success,
    required this.message,
  });

  factory AdminRejectDelegateResponseModel.fromJson(Map<String, dynamic> json) {
    return AdminRejectDelegateResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
