import '../../../../core/api/api_manager.dart';
import '../../../../core/api/endpoints.dart';
import '../models/profile_model.dart';
import 'package:injectable/injectable.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileResponseModel> getProfile();
  Future<AddAddressResponseModel> addAddress({
    required String label,
    required String address,
    required String city,
    required double lat,
    required double lng,
  });
}

@LazySingleton(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiManager _apiManager;

  ProfileRemoteDataSourceImpl(this._apiManager);

  @override
  Future<ProfileResponseModel> getProfile() async {
    final response = await _apiManager.getDate(Endpoints.profile);

    if (response.data != null) {
      final profileMap = Map<String, dynamic>.from(response.data);

      try {
        final addressesResponse = await _apiManager.getDate(Endpoints.addresses);
        if (addressesResponse.data != null && addressesResponse.data['success'] == true) {
          final addressesData = addressesResponse.data['data'];
          if (addressesData != null) {
            final List<dynamic> addressesList = addressesData['addresses'] ?? [];
            if (profileMap['data'] != null && profileMap['data']['user'] != null) {
              final userMap = Map<String, dynamic>.from(profileMap['data']['user']);
              userMap['addresses'] = addressesList;
              
              final dataMap = Map<String, dynamic>.from(profileMap['data']);
              dataMap['user'] = userMap;
              
              profileMap['data'] = dataMap;
            }
          }
        }
      } catch (e) {
        // Suppress error so profile info is still shown even if address fetch fails
      }

      return ProfileResponseModel.fromJson(profileMap);
    } else {
      throw Exception('فشل في جلب بيانات الملف الشخصي');
    }
  }

  @override
  Future<AddAddressResponseModel> addAddress({
    required String label,
    required String address,
    required String city,
    required double lat,
    required double lng,
  }) async {
    final body = {
      'label': label,
      'address': address,
      'city': city,
      'coordinates': {
        'lat': lat,
        'lng': lng,
      }
    };

    final response = await _apiManager.PostDate(
      Endpoints.addresses,
      body: body,
    );

    if (response.data != null) {
      return AddAddressResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في إضافة العنوان');
    }
  }
}
