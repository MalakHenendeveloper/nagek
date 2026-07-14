import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/get_admin_center_details_use_case.dart';
import '../../domain/use_cases/update_admin_center_status_use_case.dart';
import '../../domain/entities/admin_center_details_entity.dart';
import 'admin_center_details_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class AdminCenterDetailsCubit extends Cubit<AdminCenterDetailsState> {
  final GetAdminCenterDetailsUseCase _getCenterDetailsUseCase;
  final UpdateAdminCenterStatusUseCase _updateCenterStatusUseCase;

  AdminCenterDetailsCubit(
    this._getCenterDetailsUseCase,
    this._updateCenterStatusUseCase,
  ) : super(const AdminCenterDetailsInitial());

  Future<void> fetchCenterDetails(String centerId) async {
    emit(const AdminCenterDetailsLoading());

    final result = await _getCenterDetailsUseCase.call(centerId);

    result.fold(
      (failure) => emit(AdminCenterDetailsError(failure.message)),
      (details) => emit(AdminCenterDetailsLoaded(details)),
    );
  }

  Future<void> updateCenterStatus(String centerId, String status) async {
    final currentState = state;
    AdminCenterDetailsEntity? details;
    if (currentState is AdminCenterDetailsLoaded) {
      details = currentState.details;
    } else if (currentState is AdminCenterDetailsLoadingStatus) {
      details = currentState.details;
    } else if (currentState is AdminCenterStatusUpdateError) {
      details = currentState.details;
    }

    if (details != null) {
      emit(AdminCenterDetailsLoadingStatus(details));

      final result = await _updateCenterStatusUseCase.call(
        centerId: centerId,
        status: status,
      );

      result.fold(
        (failure) => emit(AdminCenterStatusUpdateError(details!, failure.message)),
        (updatedCenter) {
          // Reconstruct details entity with the updated center object
          // Wait, the updated center response does not include the owner object fully populated if it returned a simple String ID,
          // so we preserve the old owner object to prevent UI null pointer exceptions!
          final centerWithOwner = updatedCenter.copyWith(
            owner: details!.center.owner,
          );
          
          final updatedDetails = AdminCenterDetailsEntity(
            center: centerWithOwner,
            services: details.services,
            statistics: details.statistics,
          );
          emit(AdminCenterDetailsLoaded(updatedDetails));
        },
      );
    }
  }
}
