import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase({required AuthRepository repository}) : _repository = repository;

  Future<Either<Failure, User?>> call() async {
    return await _repository.getCurrentUser();
  }
}
