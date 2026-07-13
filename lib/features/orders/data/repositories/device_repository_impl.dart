import 'package:injectable/injectable.dart';
import '../../domain/repositories/device_repository.dart';
import '../data_sources/device_local_data_source.dart';
import '../models/device_model.dart';

@LazySingleton(as: DeviceRepository)
class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceLocalDataSource _localDataSource;

  DeviceRepositoryImpl(this._localDataSource);

  @override
  Future<List<BrandModel>> getBrands() {
    return _localDataSource.getBrands();
  }
}
