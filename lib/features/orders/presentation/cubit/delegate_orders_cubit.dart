import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/get_delegate_orders_use_case.dart';
import '../../domain/use_cases/upload_pickup_photos_use_case.dart';
import '../../domain/use_cases/confirm_pickup_use_case.dart';
import '../../domain/use_cases/confirm_drop_center_use_case.dart';
import '../../domain/use_cases/confirm_pickup_center_use_case.dart';
import '../../domain/use_cases/confirm_delivery_use_case.dart';
import 'delegate_orders_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class DelegateOrdersCubit extends Cubit<DelegateOrdersState> {
  final GetDelegateOrdersUseCase _getDelegateOrdersUseCase;
  final UploadPickupPhotosUseCase _uploadPickupPhotosUseCase;
  final ConfirmPickupUseCase _confirmPickupUseCase;
  final ConfirmDropCenterUseCase _confirmDropCenterUseCase;
  final ConfirmPickupCenterUseCase _confirmPickupCenterUseCase;
  final ConfirmDeliveryUseCase _confirmDeliveryUseCase;

  DelegateOrdersCubit(
    this._getDelegateOrdersUseCase,
    this._uploadPickupPhotosUseCase,
    this._confirmPickupUseCase,
    this._confirmDropCenterUseCase,
    this._confirmPickupCenterUseCase,
    this._confirmDeliveryUseCase,
  ) : super(DelegateOrdersInitial());

  Future<void> fetchDelegateOrders() async {
    emit(DelegateOrdersLoading());

    final result = await _getDelegateOrdersUseCase.call();

    result.fold(
      (failure) => emit(DelegateOrdersError(failure.message)),
      (orders) {
        // Calculate completed orders count from status
        int completedCount = 0;
        for (final order in orders) {
          final status = order.status.toLowerCase();
          if (status == 'delivered' || status == 'completed') {
            completedCount++;
          }
        }

        emit(DelegateOrdersLoaded(orders, completedCount, 0.0));
      },
    );
  }

  Future<void> uploadPhotosAndConfirm(String orderId, List<String> imagePaths) async {
    // Step 1: Upload photos
    emit(DelegateOrdersUploadLoading(orderId));

    final uploadResult = await _uploadPickupPhotosUseCase.call(orderId, imagePaths);

    await uploadResult.fold(
      (failure) {
        emit(DelegateOrdersUploadError(failure.message));
      },
      (photoUrls) async {
        emit(DelegateOrdersUploadSuccess(photoUrls));

        // Step 2: Confirm pickup
        emit(DelegateOrdersConfirmLoading(orderId));

        final confirmResult = await _confirmPickupUseCase.call(orderId);

        confirmResult.fold(
          (failure) => emit(DelegateOrdersConfirmError(failure.message)),
          (confirmedOrder) {
            emit(DelegateOrdersConfirmSuccess(confirmedOrder));
            fetchDelegateOrders();
          },
        );
      },
    );
  }

  Future<void> confirmDropCenter(String orderId, List<String> imagePaths) async {
    emit(DelegateOrdersDropCenterLoading(orderId));

    final result = await _confirmDropCenterUseCase.call(orderId, imagePaths);

    result.fold(
      (failure) => emit(DelegateOrdersDropCenterError(failure.message)),
      (order) async {
        emit(DelegateOrdersDropCenterSuccess(order));
        await Future.delayed(const Duration(milliseconds: 300));
        fetchDelegateOrders();
      },
    );
  }

  Future<void> confirmPickupCenter(String orderId, List<String> imagePaths) async {
    emit(DelegateOrdersPickupCenterLoading(orderId));

    final result = await _confirmPickupCenterUseCase.call(orderId, imagePaths);

    result.fold(
      (failure) => emit(DelegateOrdersPickupCenterError(failure.message)),
      (order) async {
        emit(DelegateOrdersPickupCenterSuccess(order));
        await Future.delayed(const Duration(milliseconds: 300));
        fetchDelegateOrders();
      },
    );
  }

  Future<void> confirmDelivery(String orderId, List<String> imagePaths) async {
    emit(DelegateOrdersConfirmDeliveryLoading(orderId));

    final result = await _confirmDeliveryUseCase.call(orderId, imagePaths);

    result.fold(
      (failure) => emit(DelegateOrdersConfirmDeliveryError(failure.message)),
      (order) async {
        emit(DelegateOrdersConfirmDeliverySuccess(order));
        await Future.delayed(const Duration(milliseconds: 300));
        fetchDelegateOrders();
      },
    );
  }
}
