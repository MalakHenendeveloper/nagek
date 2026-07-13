import 'package:injectable/injectable.dart';
import '../../../../core/data/devices_data.dart';
import '../models/device_model.dart';

abstract class DeviceLocalDataSource {
  Future<List<BrandModel>> getBrands();
}

@LazySingleton(as: DeviceLocalDataSource)
class DeviceLocalDataSourceImpl implements DeviceLocalDataSource {
  @override
  Future<List<BrandModel>> getBrands() async {
    return DevicesData.brands;
  }
}
