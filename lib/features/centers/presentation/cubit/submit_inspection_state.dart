import '../../../orders/domain/entities/inspection_entity.dart';

abstract class SubmitInspectionState {}

class SubmitInspectionInitial extends SubmitInspectionState {}

class SubmitInspectionLoading extends SubmitInspectionState {}

class SubmitInspectionSuccess extends SubmitInspectionState {
  final InspectionEntity inspection;
  SubmitInspectionSuccess(this.inspection);
}

class SubmitInspectionError extends SubmitInspectionState {
  final String message;
  SubmitInspectionError(this.message);
}
