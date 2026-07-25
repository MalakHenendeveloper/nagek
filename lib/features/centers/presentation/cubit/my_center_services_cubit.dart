import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/use_cases/get_my_center_services_use_case.dart';
import 'my_center_services_state.dart';

@injectable
class MyCenterServicesCubit extends Cubit<MyCenterServicesState> {
  final GetMyCenterServicesUseCase _getMyCenterServicesUseCase;

  MyCenterServicesCubit(this._getMyCenterServicesUseCase)
      : super(MyCenterServicesInitial());

  Future<void> fetchMyServices() async {
    emit(MyCenterServicesLoading());

    final result = await _getMyCenterServicesUseCase.call();

    result.fold(
      (failure) => emit(MyCenterServicesError(failure.message)),
      (services) => emit(MyCenterServicesLoaded(services)),
    );
  }
}
