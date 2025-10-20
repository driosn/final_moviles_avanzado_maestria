import '../../../stores/domain/entities/store.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/store_assignment_repository.dart';
import '../datasources/store_assignment_remote_datasource.dart';

class StoreAssignmentRepositoryImpl implements StoreAssignmentRepository {
  final StoreAssignmentRemoteDataSource remoteDataSource;

  StoreAssignmentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Store>> getAllStores() async {
    return await remoteDataSource.getAllStores();
  }

  @override
  Future<List<Store>> getUserAssignedStores() async {
    return await remoteDataSource.getUserAssignedStores();
  }

  @override
  Future<List<User>> getUsersByRole(UserRole role) async {
    return await remoteDataSource.getUsersByRole(role);
  }

  @override
  Future<List<User>> getAssignedUsers(String storeId) async {
    return await remoteDataSource.getAssignedUsers(storeId);
  }

  @override
  Future<List<User>> getAvailableUsers(String storeId) async {
    return await remoteDataSource.getAvailableUsers(storeId);
  }

  @override
  Future<void> assignUserToStore(String userId, String storeId) async {
    return await remoteDataSource.assignUserToStore(userId, storeId);
  }

  @override
  Future<void> removeUserFromStore(String userId, String storeId) async {
    return await remoteDataSource.removeUserFromStore(userId, storeId);
  }
}
