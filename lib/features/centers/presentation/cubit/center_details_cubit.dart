import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/center_entity.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/use_cases/get_center_details_use_case.dart';
import '../../domain/use_cases/get_center_services_use_case.dart';
import 'center_details_state.dart';

@injectable
class CenterDetailsCubit extends Cubit<CenterDetailsState> {
  final GetCenterDetailsUseCase _getCenterDetailsUseCase;
  final GetCenterServicesUseCase _getCenterServicesUseCase;

  CenterDetailsCubit(
    this._getCenterDetailsUseCase,
    this._getCenterServicesUseCase,
  ) : super(CenterDetailsInitial());

  Future<void> fetchCenterDetails(String id) async {
    emit(CenterDetailsLoading());
    
    final results = await Future.wait([
      _getCenterDetailsUseCase(id),
      _getCenterServicesUseCase(id),
    ]);

    final centerResult = results[0] as Either<Failure, CenterEntity>;
    final servicesResult = results[1] as Either<Failure, List<ServiceEntity>>;

    centerResult.fold(
      (failure) => emit(CenterDetailsError(failure.message)),
      (center) {
        servicesResult.fold(
          (failure) => emit(CenterDetailsError(failure.message)),
          (services) => emit(CenterDetailsLoaded(center, services)),
        );
      },
    );
  }
}
