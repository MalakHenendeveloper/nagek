import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/create_order_use_case.dart';
import 'create_order_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class CreateOrderCubit extends Cubit<CreateOrderState> {
  final CreateOrderUseCase _createOrderUseCase;

  CreateOrderCubit(this._createOrderUseCase) : super(CreateOrderInitial());

  Future<void> createOrder({
    required String centerId,
    required String deviceType,
    required String brand,
    required String model,
    required String problemType,
    required String problemDescription,
    required List<String> imagePaths,
    required String address,
    required String city,
  }) async {
    emit(CreateOrderLoading());

    final result = await _createOrderUseCase.call(
      centerId: centerId,
      deviceType: deviceType,
      brand: brand,
      model: model,
      problemType: problemType,
      problemDescription: problemDescription,
      imagePaths: imagePaths,
      address: address,
      city: city,
    );

    result.fold(
      (failure) => emit(CreateOrderError(failure.message)),
      (order) => emit(CreateOrderSuccess(order)),
    );
  }
}
