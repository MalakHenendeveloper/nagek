import '../../data/models/device_model.dart';

abstract class DeviceRepository {
  Future<List<BrandModel>> getBrands();
}
