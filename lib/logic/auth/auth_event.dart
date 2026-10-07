import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class RegisterRequested extends AuthEvent {
  final String username;
  final String email;
  final String password;

  const RegisterRequested({
    required this.username,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [username, email, password];
}

class LoginRequested extends AuthEvent {
  final String input;
  final String password;

  const LoginRequested({required this.input, required this.password});

  @override
  List<Object?> get props => [input, password];
}

class LogoutRequested extends AuthEvent {}
