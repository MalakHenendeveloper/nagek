import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/get_delegate_orders_use_case.dart';
import '../../domain/use_cases/upload_pickup_photos_use_case.dart';
import '../../domain/use_cases/confirm_pickup_use_case.dart';
import '../../domain/use_cases/confirm_drop_center_use_case.dart';
import 'delegate_orders_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class DelegateOrdersCubit extends Cubit<DelegateOrdersState> {
  final GetDelegateOrdersUseCase _getDelegateOrdersUseCase;
  final UploadPickupPhotosUseCase _uploadPickupPhotosUseCase;
  final ConfirmPickupUseCase _confirmPickupUseCase;
  final ConfirmDropCenterUseCase _confirmDropCenterUseCase;

  DelegateOrdersCubit(
    this._getDelegateOrdersUseCase,
    this._uploadPickupPhotosUseCase,
    this._confirmPickupUseCase,
    this._confirmDropCenterUseCase,
  ) : super(DelegateOrdersInitial());

  Future<void> fetchDelegateOrders() async {
    emit(DelegateOrdersLoading());

    final result = await _getDelegateOrdersUseCase.call();

    result.fold(
      (failure) => emit(DelegateOrdersError(failure.message)),
      (orders) {
        // Calculate completed orders count & total earnings
        int completedCount = 0;
        double totalEarnings = 0.0;

        for (final order in orders) {
          final status = order.status.toLowerCase();
          if (status == 'delivered' || status == 'completed') {
            completedCount++;
            totalEarnings += order.fees.delivery;
          }
        }

        emit(DelegateOrdersLoaded(orders, completedCount, totalEarnings));
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
      (order) {
        emit(DelegateOrdersDropCenterSuccess(order));
        fetchDelegateOrders();
      },
    );
  }
}
