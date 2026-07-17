import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/device_repository.dart';
import '../../data/models/device_model.dart';
import 'device_selection_state.dart';

@injectable
class DeviceSelectionCubit extends Cubit<DeviceSelectionState> {
  final DeviceRepository _deviceRepository;

  DeviceSelectionCubit(this._deviceRepository)
    : super(DeviceSelectionState.initial());

  Future<void> loadBrands() async {
    final brands = await _deviceRepository.getBrands();
    emit(
      state.copyWith(
        brands: brands,
        filteredDevices: brands.expand((b) => b.devices).toList(),
      ),
    );
  }

  void filterDevices({String? query, BrandModel? Function()? brand}) {
    final search = query ?? state.searchQuery;
    final selectedB = brand != null ? brand() : state.selectedBrand;

    List<DeviceModel> allDevices = [];
    if (selectedB != null) {
      allDevices = selectedB.devices;
    } else {
      for (var b in state.brands) {
        allDevices.addAll(b.devices);
      }
    }

    List<DeviceModel> filtered;
    if (search.trim().isEmpty) {
      filtered = allDevices;
    } else {
      final lowercaseQuery = search.trim().toLowerCase();
      filtered = allDevices.where((device) {
        return device.model.toLowerCase().contains(lowercaseQuery) ||
            device.brand.toLowerCase().contains(lowercaseQuery) ||
            device.series.toLowerCase().contains(lowercaseQuery);
      }).toList();
    }

    emit(
      state.copyWith(
        searchQuery: search,
        selectedBrand: brand ?? () => state.selectedBrand,
        filteredDevices: filtered,
      ),
    );
  }

  void selectBrand(BrandModel? brand) {
    emit(state.copyWith(selectedDevice: () => null, manualDevice: () => null));
    filterDevices(brand: () => brand);
  }

  void selectDevice(DeviceModel? device) {
    emit(
      state.copyWith(selectedDevice: () => device, manualDevice: () => null),
    );
  }

  void setManualDevice(String? modelName) {
    emit(
      state.copyWith(
        selectedDevice: () => null,
        manualDevice: () =>
            (modelName != null && modelName.trim().isEmpty) ? null : modelName,
      ),
    );
  }

  void clearSelection() {
    emit(
      state.copyWith(
        selectedBrand: () => null,
        selectedDevice: () => null,
        manualDevice: () => null,
        searchQuery: '',
        filteredDevices: state.brands.expand((b) => b.devices).toList(),
      ),
    );
  }
}
