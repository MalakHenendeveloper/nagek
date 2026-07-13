import '../../data/models/device_model.dart';

class DeviceSelectionState {
  final List<BrandModel> brands;
  final List<DeviceModel> filteredDevices;
  final BrandModel? selectedBrand;
  final DeviceModel? selectedDevice;
  final String searchQuery;
  final String? manualDevice;

  DeviceSelectionState({
    required this.brands,
    required this.filteredDevices,
    this.selectedBrand,
    this.selectedDevice,
    required this.searchQuery,
    this.manualDevice,
  });

  factory DeviceSelectionState.initial() {
    return DeviceSelectionState(
      brands: [],
      filteredDevices: [],
      selectedBrand: null,
      selectedDevice: null,
      searchQuery: '',
      manualDevice: null,
    );
  }

  DeviceSelectionState copyWith({
    List<BrandModel>? brands,
    List<DeviceModel>? filteredDevices,
    BrandModel? Function()? selectedBrand,
    DeviceModel? Function()? selectedDevice,
    String? searchQuery,
    String? Function()? manualDevice,
  }) {
    return DeviceSelectionState(
      brands: brands ?? this.brands,
      filteredDevices: filteredDevices ?? this.filteredDevices,
      selectedBrand: selectedBrand != null ? selectedBrand() : this.selectedBrand,
      selectedDevice: selectedDevice != null ? selectedDevice() : this.selectedDevice,
      searchQuery: searchQuery ?? this.searchQuery,
      manualDevice: manualDevice != null ? manualDevice() : this.manualDevice,
    );
  }
}
