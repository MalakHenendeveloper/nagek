import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/use_cases/get_profile_use_case.dart';
import 'profile_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUseCase _getProfileUseCase;
  final ProfileRepository _profileRepository;

  ProfileCubit(this._getProfileUseCase, this._profileRepository)
      : super(ProfileInitial());

  ProfileUserEntity? _lastUser;

  Future<void> fetchProfile() async {
    emit(ProfileLoading());
    final result = await _getProfileUseCase();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (user) {
        _lastUser = user;
        emit(ProfileLoaded(user));
      },
    );
  }

  Future<void> addAddress({
    required String label,
    required String address,
    required String city,
    required double lat,
    required double lng,
  }) async {
    emit(AddAddressLoading());
    final result = await _profileRepository.addAddress(
      label: label,
      address: address,
      city: city,
      lat: lat,
      lng: lng,
    );

    result.fold(
      (failure) => emit(AddAddressError(failure.message)),
      (addresses) {
        if (_lastUser != null) {
          final updatedUser = ProfileUserEntity(
            id: _lastUser!.id,
            name: _lastUser!.name,
            phone: _lastUser!.phone,
            email: _lastUser!.email,
            role: _lastUser!.role,
            isActive: _lastUser!.isActive,
            isVerified: _lastUser!.isVerified,
            addresses: addresses,
            createdAt: _lastUser!.createdAt,
          );
          _lastUser = updatedUser;
          emit(AddAddressSuccess('تم إضافة العنوان بنجاح', updatedUser));
        }
      },
    );
  }
}

