import 'login_response.dart';

class DelegateLoginResponseModel {
  final bool? success;
  final String? message;
  final String? status;
  final String? rejectReason;
  final LoginDataModel? data;

  DelegateLoginResponseModel({
    this.success,
    this.message,
    this.status,
    this.rejectReason,
    this.data,
  });

  factory DelegateLoginResponseModel.fromJson(Map<String, dynamic> json) {
    return DelegateLoginResponseModel(
      success: json['success'],
      message: json['message'],
      status: json['status'],
      rejectReason: json['rejectReason'],
      data: json['data'] != null ? LoginDataModel.fromJson(json['data']) : null,
    );
  }
}
