import '../../domain/entities/center_entity.dart';

abstract class CenterDetailsState {}

class CenterDetailsInitial extends CenterDetailsState {}

class CenterDetailsLoading extends CenterDetailsState {}

class CenterDetailsLoaded extends CenterDetailsState {
  final CenterEntity center;

  CenterDetailsLoaded(this.center);
}

class CenterDetailsError extends CenterDetailsState {
  final String message;

  CenterDetailsError(this.message);
}
