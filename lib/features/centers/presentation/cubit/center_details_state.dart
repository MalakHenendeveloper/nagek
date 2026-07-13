import '../../domain/entities/center_entity.dart';
import '../../domain/entities/service_entity.dart';

abstract class CenterDetailsState {}

class CenterDetailsInitial extends CenterDetailsState {}

class CenterDetailsLoading extends CenterDetailsState {}

class CenterDetailsLoaded extends CenterDetailsState {
  final CenterEntity center;
  final List<ServiceEntity> services;

  CenterDetailsLoaded(this.center, this.services);
}

class CenterDetailsError extends CenterDetailsState {
  final String message;

  CenterDetailsError(this.message);
}
