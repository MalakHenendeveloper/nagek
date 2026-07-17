import '../../domain/entities/center_order_details_entity.dart';

abstract class CenterOrderDetailsState {}

class CenterOrderDetailsInitial extends CenterOrderDetailsState {}

class CenterOrderDetailsLoading extends CenterOrderDetailsState {}

class CenterOrderDetailsLoaded extends CenterOrderDetailsState {
  final CenterOrderDetailsEntity details;

  CenterOrderDetailsLoaded(this.details);
}

class CenterOrderDetailsError extends CenterOrderDetailsState {
  final String message;

  CenterOrderDetailsError(this.message);
}

class CenterOrderStatusUpdateLoading extends CenterOrderDetailsState {}

class CenterOrderStatusUpdateSuccess extends CenterOrderDetailsState {}

class CenterOrderStatusUpdateError extends CenterOrderDetailsState {
  final String message;

  CenterOrderStatusUpdateError(this.message);
}
