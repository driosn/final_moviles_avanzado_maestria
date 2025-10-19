import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/store.dart';
import '../repositories/stores_repository.dart';

class CreateStoreUseCase {
  final StoresRepository _repository;

  CreateStoreUseCase({required StoresRepository repository}) : _repository = repository;

  Future<Either<Failure, Store>> call({required String name, required City city}) async {
    // Validate inputs
    if (name.isEmpty) {
      return const Left(ValidationFailure('El nombre de la tienda es requerido'));
    }

    if (name.length < 2) {
      return const Left(ValidationFailure('El nombre debe tener al menos 2 caracteres'));
    }

    return await _repository.createStore(name: name, city: city);
  }
}
