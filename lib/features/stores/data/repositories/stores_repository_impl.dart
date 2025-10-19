import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/store.dart';
import '../../domain/repositories/stores_repository.dart';
import '../datasources/stores_remote_datasource.dart';

class StoresRepositoryImpl implements StoresRepository {
  final StoresRemoteDataSource _remoteDataSource;

  StoresRepositoryImpl({required StoresRemoteDataSource remoteDataSource}) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<Store>>> getAllStores() async {
    try {
      final stores = await _remoteDataSource.getAllStores();
      return Right(stores);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Store>> getStoreById(String id) async {
    try {
      final store = await _remoteDataSource.getStoreById(id);
      return Right(store);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Store>> createStore({required String name, required City city}) async {
    try {
      final store = await _remoteDataSource.createStore(name: name, city: city);
      return Right(store);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Store>> updateStore({required String id, required String name, required City city}) async {
    try {
      final store = await _remoteDataSource.updateStore(id: id, name: name, city: city);
      return Right(store);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteStore(String id) async {
    try {
      await _remoteDataSource.deleteStore(id);
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }
}
