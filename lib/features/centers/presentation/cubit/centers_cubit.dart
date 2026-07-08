import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/get_centers_use_case.dart';
import 'centers_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class CentersCubit extends Cubit<CentersState> {
  final GetCentersUseCase _getCentersUseCase;
  
  int _currentPage = 1;
  bool _isFetching = false;

  CentersCubit(this._getCentersUseCase) : super(CentersInitial());

  Future<void> fetchCenters({int limit = 10, bool isRefresh = false}) async {
    if (_isFetching) return;
    
    if (isRefresh) {
      _currentPage = 1;
      emit(CentersLoading());
    }

    final currentState = state;
    if (currentState is CentersLoaded && currentState.hasReachedMax && !isRefresh) return;

    _isFetching = true;
    
    if (currentState is! CentersLoaded) {
      emit(CentersLoading());
    }

    final result = await _getCentersUseCase(page: _currentPage, limit: limit);
    
    result.fold(
      (failure) {
        if (currentState is CentersLoaded) {
          emit(CentersError(failure.message));
          emit(currentState); // fallback to previous state
        } else {
          emit(CentersError(failure.message));
        }
      },
      (data) {
        _currentPage++;
        final isMax = data.pagination.page >= data.pagination.pages;
        
        if (currentState is CentersLoaded && !isRefresh) {
          emit(CentersLoaded(
            centers: currentState.centers + data.centers,
            hasReachedMax: isMax,
          ));
        } else {
          emit(CentersLoaded(
            centers: data.centers,
            hasReachedMax: isMax,
          ));
        }
      },
    );
    _isFetching = false;
  }
}
