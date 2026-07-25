import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/use_cases/get_center_service_details_use_case.dart';
import 'center_service_details_state.dart';

@injectable
class CenterServiceDetailsCubit extends Cubit<CenterServiceDetailsState> {
  final GetCenterServiceDetailsUseCase _getCenterServiceDetailsUseCase;

  CenterServiceDetailsCubit(this._getCenterServiceDetailsUseCase)
      : super(CenterServiceDetailsInitial());

  Future<void> fetchServiceDetails(String serviceId) async {
    emit(CenterServiceDetailsLoading());

    final result = await _getCenterServiceDetailsUseCase.call(serviceId);

    result.fold(
      (failure) => emit(CenterServiceDetailsError(failure.message)),
      (service) => emit(CenterServiceDetailsLoaded(service)),
    );
  }
}
