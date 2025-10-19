import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository _repository;

  SignUpUseCase({required AuthRepository repository}) : _repository = repository;

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    // Validate inputs
    if (email.isEmpty) {
      return const Left(ValidationFailure('El email es requerido'));
    }

    if (password.isEmpty) {
      return const Left(ValidationFailure('La contraseña es requerida'));
    }

    if (name.isEmpty) {
      return const Left(ValidationFailure('El nombre es requerido'));
    }

    if (!_isValidEmail(email)) {
      return const Left(ValidationFailure('El formato del email no es válido'));
    }

    if (password.length < 6) {
      return const Left(ValidationFailure('La contraseña debe tener al menos 6 caracteres'));
    }

    return await _repository.signUpWithEmail(email: email, password: password, name: name, role: role);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
