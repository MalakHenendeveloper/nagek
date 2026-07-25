import '../../domain/entities/service_entity.dart';

abstract class AddCenterServiceState {}

class AddCenterServiceInitial extends AddCenterServiceState {}

class AddCenterServiceLoading extends AddCenterServiceState {}

class AddCenterServiceSuccess extends AddCenterServiceState {
  final String message;
  final ServiceEntity service;

  AddCenterServiceSuccess({
    required this.message,
    required this.service,
  });
}

class AddCenterServiceError extends AddCenterServiceState {
  final String message;

  AddCenterServiceError(this.message);
}
