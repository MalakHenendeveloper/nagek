import '../../../../core/api/api_manager.dart';
import '../../../../core/api/endpoints.dart';
import '../models/center_model.dart';

import '../models/center_details_response.dart';

import 'package:injectable/injectable.dart';

abstract class CentersRemoteDataSource {
  Future<CentersResponseModel> getCenters({
    required int page,
    required int limit,
  });

  Future<CenterDetailsResponseModel> getCenterDetails(String id);
}

@LazySingleton(as: CentersRemoteDataSource)
class CentersRemoteDataSourceImpl implements CentersRemoteDataSource {
  final ApiManager _apiManager;

  CentersRemoteDataSourceImpl(this._apiManager);

  @override
  Future<CentersResponseModel> getCenters({
    required int page,
    required int limit,
  }) async {
    final response = await _apiManager.getDate(
      '${Endpoints.centers}?page=$page&limit=$limit',
    );

    if (response.data != null) {
      return CentersResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب مراكز الصيانة');
    }
  }

  @override
  Future<CenterDetailsResponseModel> getCenterDetails(String id) async {
    final response = await _apiManager.getDate(
      '${Endpoints.centerDetails}$id',
    );

    if (response.data != null) {
      return CenterDetailsResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في جلب تفاصيل المركز');
    }
  }
}
