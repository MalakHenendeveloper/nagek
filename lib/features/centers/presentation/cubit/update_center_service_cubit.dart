import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/use_cases/update_center_service_use_case.dart';
import 'update_center_service_state.dart';

@injectable
class UpdateCenterServiceCubit extends Cubit<UpdateCenterServiceState> {
  final UpdateCenterServiceUseCase _updateCenterServiceUseCase;

  UpdateCenterServiceCubit(this._updateCenterServiceUseCase)
      : super(UpdateCenterServiceInitial());

  Future<void> updateService({
    required String serviceId,
    required String serviceName,
    required String description,
    required double price,
    required String estimatedTime,
    required bool isAvailable,
  }) async {
    emit(UpdateCenterServiceLoading());

    final result = await _updateCenterServiceUseCase.call(
      serviceId: serviceId,
      serviceName: serviceName,
      description: description,
      price: price,
      estimatedTime: estimatedTime,
      isAvailable: isAvailable,
    );

    result.fold(
      (failure) => emit(UpdateCenterServiceError(failure.message)),
      (service) => emit(UpdateCenterServiceSuccess(service)),
    );
  }
}
