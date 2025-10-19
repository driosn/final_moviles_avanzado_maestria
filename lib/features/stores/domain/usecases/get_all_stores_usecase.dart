import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/store.dart';
import '../repositories/stores_repository.dart';

class GetAllStoresUseCase {
  final StoresRepository _repository;

  GetAllStoresUseCase({required StoresRepository repository}) : _repository = repository;

  Future<Either<Failure, List<Store>>> call() async {
    return await _repository.getAllStores();
  }
}
