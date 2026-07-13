import '../../domain/entities/profile_entity.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileUserEntity user;
  ProfileLoaded(this.user);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

class AddAddressLoading extends ProfileState {}

class AddAddressSuccess extends ProfileState {
  final String message;
  final ProfileUserEntity user;
  AddAddressSuccess(this.message, this.user);
}

class AddAddressError extends ProfileState {
  final String message;
  AddAddressError(this.message);
}
