import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/register_use_case.dart';
import 'register_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class RegisterCubit extends Cubit<RegisterState> {
  final RegisterUseCase _registerUseCase;

  RegisterCubit(this._registerUseCase) : super(RegisterInitial());

  Future<void> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    emit(RegisterLoading());
    final result = await _registerUseCase(
      name: name,
      phone: phone,
      email: email,
      password: password,
    );

    result.fold(
      (failure) => emit(RegisterError(message: failure.message)),
      (user) => emit(RegisterSuccess()),
    );
  }
}
