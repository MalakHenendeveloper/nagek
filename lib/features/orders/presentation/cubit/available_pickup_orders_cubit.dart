import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/get_available_pickup_orders_use_case.dart';
import '../../domain/use_cases/get_available_delivery_orders_use_case.dart';
import '../../domain/use_cases/accept_pickup_use_case.dart';
import '../../domain/use_cases/upload_pickup_photos_use_case.dart';
import '../../domain/use_cases/confirm_pickup_use_case.dart';
import '../../domain/entities/order_entity.dart';
import 'available_pickup_orders_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class AvailablePickupOrdersCubit extends Cubit<AvailablePickupOrdersState> {
  final GetAvailablePickupOrdersUseCase _getAvailablePickupOrdersUseCase;
  final GetAvailableDeliveryOrdersUseCase _getAvailableDeliveryOrdersUseCase;
  final AcceptPickupUseCase _acceptPickupUseCase;
  final UploadPickupPhotosUseCase _uploadPickupPhotosUseCase;
  final ConfirmPickupUseCase _confirmPickupUseCase;

  AvailablePickupOrdersCubit(
    this._getAvailablePickupOrdersUseCase,
    this._getAvailableDeliveryOrdersUseCase,
    this._acceptPickupUseCase,
    this._uploadPickupPhotosUseCase,
    this._confirmPickupUseCase,
  ) : super(AvailablePickupOrdersInitial());

  Future<void> fetchAvailablePickupOrders() async {
    emit(AvailablePickupOrdersLoading());

    final results = await Future.wait([
      _getAvailablePickupOrdersUseCase.call(),
      _getAvailableDeliveryOrdersUseCase.call(),
    ]);

    final pickupResult = results[0];
    final deliveryResult = results[1];

    List<OrderEntity> pickupOrders = [];
    List<OrderEntity> deliveryOrders = [];
    String? errorMessage;

    pickupResult.fold(
      (failure) => errorMessage = failure.message,
      (orders) => pickupOrders = orders,
    );

    deliveryResult.fold(
      (failure) => errorMessage ??= failure.message,
      (orders) => deliveryOrders = orders,
    );

    if (pickupOrders.isEmpty && deliveryOrders.isEmpty && errorMessage != null) {
      emit(AvailablePickupOrdersError(errorMessage!));
    } else {
      emit(AvailablePickupOrdersLoaded(
        pickupOrders: pickupOrders,
        deliveryOrders: deliveryOrders,
      ));
    }
  }

  Future<void> acceptUploadAndConfirm(String orderId, List<String> imagePaths) async {
    // Step 1: Accept pickup
    emit(AvailablePickupOrdersAcceptLoading(orderId));

    final acceptResult = await _acceptPickupUseCase.call(orderId);

    await acceptResult.fold(
      (failure) {
        emit(AvailablePickupOrdersAcceptError(failure.message));
      },
      (order) async {
        emit(AvailablePickupOrdersAcceptSuccess(order));

        // Step 2: Upload photos
        emit(AvailablePickupOrdersUploadLoading(orderId));

        final uploadResult = await _uploadPickupPhotosUseCase.call(orderId, imagePaths);

        await uploadResult.fold(
          (failure) {
            emit(AvailablePickupOrdersUploadError(failure.message));
          },
          (photoUrls) async {
            emit(AvailablePickupOrdersUploadSuccess(photoUrls));

            // Step 3: Confirm pickup
            emit(AvailablePickupOrdersConfirmLoading(orderId));

            final confirmResult = await _confirmPickupUseCase.call(orderId);

            confirmResult.fold(
              (failure) => emit(AvailablePickupOrdersConfirmError(failure.message)),
              (confirmedOrder) {
                emit(AvailablePickupOrdersConfirmSuccess(confirmedOrder));
                fetchAvailablePickupOrders();
              },
            );
          },
        );
      },
    );
  }

  Future<void> acceptPickup(String orderId) async {
    emit(AvailablePickupOrdersAcceptLoading(orderId));

    final result = await _acceptPickupUseCase.call(orderId);

    result.fold(
      (failure) => emit(AvailablePickupOrdersAcceptError(failure.message)),
      (order) {
        emit(AvailablePickupOrdersAcceptSuccess(order));
        fetchAvailablePickupOrders();
      },
    );
  }
}
