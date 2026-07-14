import '../../../../core/upload/data/models/image_upload_response.dart';

class DelegateRegisterRequestModel {
  final String name;
  final String phone;
  final String email;
  final String password;
  final ImageUploadResponse nationalIdFront;
  final ImageUploadResponse nationalIdBack;
  final ImageUploadResponse drivingLicense;
  final ImageUploadResponse motorcycleLicense;

  DelegateRegisterRequestModel({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.nationalIdFront,
    required this.nationalIdBack,
    required this.drivingLicense,
    required this.motorcycleLicense,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'password': password,
      'nationalIdFront': nationalIdFront.toJson(),
      'nationalIdBack': nationalIdBack.toJson(),
      'drivingLicense': drivingLicense.toJson(),
      'motorcycleLicense': motorcycleLicense.toJson(),
    };
  }
}
