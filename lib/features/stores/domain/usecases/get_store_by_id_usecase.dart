import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/store.dart';
import '../repositories/stores_repository.dart';

class GetStoreByIdUseCase {
  final StoresRepository _repository;

  GetStoreByIdUseCase({required StoresRepository repository}) : _repository = repository;

  Future<Either<Failure, Store>> call(String id) async {
    if (id.isEmpty) {
      return const Left(ValidationFailure('El ID de la tienda es requerido'));
    }

    return await _repository.getStoreById(id);
  }
}
