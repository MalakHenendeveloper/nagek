import '../../../../core/api/api_manager.dart';
import '../../../../core/api/endpoints.dart';
import '../models/profile_model.dart';
import 'package:injectable/injectable.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileResponseModel> getProfile();
}

@LazySingleton(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiManager _apiManager;

  ProfileRemoteDataSourceImpl(this._apiManager);

  @override
  Future<ProfileResponseModel> getProfile() async {
    final response = await _apiManager.getDate(Endpoints.profile);

    if (response.data != null) {
      return ProfileResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب بيانات الملف الشخصي');
    }
  }
}
