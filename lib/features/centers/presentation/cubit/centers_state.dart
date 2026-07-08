import '../../domain/entities/center_entity.dart';

abstract class CentersState {}

class CentersInitial extends CentersState {}

class CentersLoading extends CentersState {}

class CentersLoaded extends CentersState {
  final List<CenterEntity> centers;
  final bool hasReachedMax;

  CentersLoaded({
    required this.centers,
    required this.hasReachedMax,
  });

  CentersLoaded copyWith({
    List<CenterEntity>? centers,
    bool? hasReachedMax,
  }) {
    return CentersLoaded(
      centers: centers ?? this.centers,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class CentersError extends CentersState {
  final String message;
  CentersError(this.message);
}
