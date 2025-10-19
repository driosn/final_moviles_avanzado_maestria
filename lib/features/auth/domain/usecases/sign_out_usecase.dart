import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository _repository;

  SignOutUseCase({required AuthRepository repository}) : _repository = repository;

  Future<Either<Failure, void>> call() async {
    return await _repository.signOut();
  }
}
