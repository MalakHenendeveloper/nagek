import '../../domain/entities/center_entity.dart';

abstract class UpdateCenterProfileState {}

class UpdateCenterProfileInitial extends UpdateCenterProfileState {}

class UpdateCenterProfileLoading extends UpdateCenterProfileState {}

class UpdateCenterProfileSuccess extends UpdateCenterProfileState {
  final CenterEntity center;
  UpdateCenterProfileSuccess(this.center);
}

class UpdateCenterProfileFailure extends UpdateCenterProfileState {
  final String message;
  UpdateCenterProfileFailure(this.message);
}
