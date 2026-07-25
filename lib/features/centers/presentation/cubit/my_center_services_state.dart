import '../../domain/entities/service_entity.dart';

abstract class MyCenterServicesState {}

class MyCenterServicesInitial extends MyCenterServicesState {}

class MyCenterServicesLoading extends MyCenterServicesState {}

class MyCenterServicesLoaded extends MyCenterServicesState {
  final List<ServiceEntity> services;

  MyCenterServicesLoaded(this.services);
}

class MyCenterServicesError extends MyCenterServicesState {
  final String message;

  MyCenterServicesError(this.message);
}
