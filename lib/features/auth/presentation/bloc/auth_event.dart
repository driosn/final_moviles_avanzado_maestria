import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final UserRole role;

  const AuthSignUpRequested({required this.email, required this.password, required this.name, required this.role});

  @override
  List<Object> get props => [email, password, name, role];
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}
