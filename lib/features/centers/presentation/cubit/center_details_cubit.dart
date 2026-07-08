import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/use_cases/get_center_details_use_case.dart';
import 'center_details_state.dart';

@injectable
class CenterDetailsCubit extends Cubit<CenterDetailsState> {
  final GetCenterDetailsUseCase _getCenterDetailsUseCase;

  CenterDetailsCubit(this._getCenterDetailsUseCase) : super(CenterDetailsInitial());

  Future<void> fetchCenterDetails(String id) async {
    emit(CenterDetailsLoading());
    final result = await _getCenterDetailsUseCase(id);
    result.fold(
      (failure) => emit(CenterDetailsError(failure.message)),
      (center) => emit(CenterDetailsLoaded(center)),
    );
  }
}
