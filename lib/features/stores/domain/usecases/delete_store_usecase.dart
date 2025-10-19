import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/stores_repository.dart';

class DeleteStoreUseCase {
  final StoresRepository _repository;

  DeleteStoreUseCase({required StoresRepository repository}) : _repository = repository;

  Future<Either<Failure, void>> call(String id) async {
    if (id.isEmpty) {
      return const Left(ValidationFailure('El ID de la tienda es requerido'));
    }

    return await _repository.deleteStore(id);
  }
}
