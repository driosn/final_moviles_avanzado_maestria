import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/store.dart';

abstract class StoresRepository {
  Future<Either<Failure, List<Store>>> getAllStores();
  Future<Either<Failure, Store>> getStoreById(String id);
  Future<Either<Failure, Store>> createStore({required String name, required City city});
  Future<Either<Failure, Store>> updateStore({required String id, required String name, required City city});
  Future<Either<Failure, void>> deleteStore(String id);
}
