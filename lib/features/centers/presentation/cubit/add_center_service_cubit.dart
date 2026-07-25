import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/use_cases/add_center_service_use_case.dart';
import 'add_center_service_state.dart';

@injectable
class AddCenterServiceCubit extends Cubit<AddCenterServiceState> {
  final AddCenterServiceUseCase _addCenterServiceUseCase;

  AddCenterServiceCubit(this._addCenterServiceUseCase)
      : super(AddCenterServiceInitial());

  Future<void> addService({
    required String serviceName,
    required String description,
    required double price,
    required String estimatedTime,
    bool isAvailable = true,
  }) async {
    emit(AddCenterServiceLoading());

    final result = await _addCenterServiceUseCase.call(
      serviceName: serviceName,
      description: description,
      price: price,
      estimatedTime: estimatedTime,
      isAvailable: isAvailable,
    );

    result.fold(
      (failure) => emit(AddCenterServiceError(failure.message)),
      (service) => emit(
        AddCenterServiceSuccess(
          message: 'تم إضافة الخدمة بنجاح',
          service: service,
        ),
      ),
    );
  }
}
