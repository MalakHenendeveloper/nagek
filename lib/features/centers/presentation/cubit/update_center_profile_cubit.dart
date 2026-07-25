import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/use_cases/update_center_profile_use_case.dart';
import 'update_center_profile_state.dart';

@injectable
class UpdateCenterProfileCubit extends Cubit<UpdateCenterProfileState> {
  final UpdateCenterProfileUseCase _updateCenterProfileUseCase;

  UpdateCenterProfileCubit(this._updateCenterProfileUseCase)
      : super(UpdateCenterProfileInitial());

  Future<void> updateCenterProfile({
    required String name,
    required String phone,
    required String email,
    required String address,
    String? logoPath,
  }) async {
    emit(UpdateCenterProfileLoading());
    final result = await _updateCenterProfileUseCase.call(
      name: name,
      phone: phone,
      email: email,
      address: address,
      logoPath: logoPath,
    );

    result.fold(
      (failure) => emit(UpdateCenterProfileFailure(failure.message)),
      (center) => emit(UpdateCenterProfileSuccess(center)),
    );
  }
}
