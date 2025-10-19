import '../../../stores/domain/entities/store.dart';
import '../entities/user.dart';

abstract class StoreAssignmentRepository {
  Future<List<Store>> getAllStores();
  Future<List<User>> getUsersByRole(UserRole role);
  Future<List<User>> getAssignedUsers(String storeId);
  Future<List<User>> getAvailableUsers(String storeId);
  Future<void> assignUserToStore(String userId, String storeId);
  Future<void> removeUserFromStore(String userId, String storeId);
}
