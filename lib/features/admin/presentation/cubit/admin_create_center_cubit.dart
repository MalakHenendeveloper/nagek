import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/create_center_use_case.dart';
import 'admin_create_center_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class AdminCreateCenterCubit extends Cubit<AdminCreateCenterState> {
  final CreateCenterUseCase _createCenterUseCase;

  AdminCreateCenterCubit(this._createCenterUseCase)
      : super(const AdminCreateCenterInitial());

  Future<void> createCenter({
    required String ownerName,
    required String phone,
    required String email,
    required String password,
    required String name,
    required String address,
    required String city,
    required List<String> supportedBrands,
    required List<String> supportedDeviceTypes,
    required String? logoPath,
    required Map<String, double> coordinates,
  }) async {
    emit(const AdminCreateCenterLoading());

    final result = await _createCenterUseCase.call(
      ownerName: ownerName,
      phone: phone,
      email: email,
      password: password,
      name: name,
      address: address,
      city: city,
      supportedBrands: supportedBrands,
      supportedDeviceTypes: supportedDeviceTypes,
      logoPath: logoPath,
      coordinates: coordinates,
    );

    result.fold(
      (failure) => emit(AdminCreateCenterError(failure.message)),
      (center) => emit(AdminCreateCenterSuccess(center, 'تم إنشاء مركز الصيانة ومالك المركز بنجاح')),
    );
  }
}
