import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nic_backlog/data/repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<RegisterRequested>(_onRegisterRequested);
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final errorMsg = await authRepository.registerUser(
        username: event.username,
        email: event.email,
        password: event.password,
      );

      if (errorMsg == null) {
        emit(AuthSuccess());
      } else {
        emit(AuthFailure(errorMsg));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
