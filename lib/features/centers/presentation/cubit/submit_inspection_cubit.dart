import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/use_cases/submit_inspection_use_case.dart';
import 'submit_inspection_state.dart';

@injectable
class SubmitInspectionCubit extends Cubit<SubmitInspectionState> {
  final SubmitInspectionUseCase _useCase;

  SubmitInspectionCubit(this._useCase) : super(SubmitInspectionInitial());

  Future<void> submitInspection({
    required String orderId,
    required String technician,
    required String notes,
    required List<Map<String, String>> findings,
    required List<String> imagePaths,
  }) async {
    emit(SubmitInspectionLoading());

    final result = await _useCase(
      orderId: orderId,
      technician: technician,
      notes: notes,
      findings: findings,
      imagePaths: imagePaths,
    );

    result.fold(
      (failure) => emit(SubmitInspectionError(failure.message)),
      (inspection) => emit(SubmitInspectionSuccess(inspection)),
    );
  }
}
