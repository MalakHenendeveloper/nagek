import '../../domain/entities/service_entity.dart';

abstract class CenterServiceDetailsState {}

class CenterServiceDetailsInitial extends CenterServiceDetailsState {}

class CenterServiceDetailsLoading extends CenterServiceDetailsState {}

class CenterServiceDetailsLoaded extends CenterServiceDetailsState {
  final ServiceEntity service;

  CenterServiceDetailsLoaded(this.service);
}

class CenterServiceDetailsError extends CenterServiceDetailsState {
  final String message;

  CenterServiceDetailsError(this.message);
}
