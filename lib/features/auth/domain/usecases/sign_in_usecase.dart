import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository _repository;

  SignInUseCase({required AuthRepository repository}) : _repository = repository;

  Future<Either<Failure, User>> call({required String email, required String password}) async {
    // Validate inputs
    if (email.isEmpty) {
      return const Left(ValidationFailure('El email es requerido'));
    }

    if (password.isEmpty) {
      return const Left(ValidationFailure('La contraseña es requerida'));
    }

    if (!_isValidEmail(email)) {
      return const Left(ValidationFailure('El formato del email no es válido'));
    }

    return await _repository.signInWithEmail(email: email, password: password);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
