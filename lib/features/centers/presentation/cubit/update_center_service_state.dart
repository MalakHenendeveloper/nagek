import '../../domain/entities/service_entity.dart';

abstract class UpdateCenterServiceState {}

class UpdateCenterServiceInitial extends UpdateCenterServiceState {}

class UpdateCenterServiceLoading extends UpdateCenterServiceState {}

class UpdateCenterServiceSuccess extends UpdateCenterServiceState {
  final ServiceEntity service;
  final String message;

  UpdateCenterServiceSuccess(this.service, {this.message = 'تم تحديث الخدمة بنجاح'});
}

class UpdateCenterServiceError extends UpdateCenterServiceState {
  final String message;

  UpdateCenterServiceError(this.message);
}
