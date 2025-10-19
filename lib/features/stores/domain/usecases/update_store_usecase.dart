import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/store.dart';
import '../repositories/stores_repository.dart';

class UpdateStoreUseCase {
  final StoresRepository _repository;

  UpdateStoreUseCase({required StoresRepository repository}) : _repository = repository;

  Future<Either<Failure, Store>> call({required String id, required String name, required City city}) async {
    // Validate inputs
    if (id.isEmpty) {
      return const Left(ValidationFailure('El ID de la tienda es requerido'));
    }

    if (name.isEmpty) {
      return const Left(ValidationFailure('El nombre de la tienda es requerido'));
    }

    if (name.length < 2) {
      return const Left(ValidationFailure('El nombre debe tener al menos 2 caracteres'));
    }

    return await _repository.updateStore(id: id, name: name, city: city);
  }
}
