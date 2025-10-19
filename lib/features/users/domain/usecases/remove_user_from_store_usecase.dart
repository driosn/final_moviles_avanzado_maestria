import '../repositories/store_assignment_repository.dart';

class RemoveUserFromStoreUseCase {
  final StoreAssignmentRepository repository;

  RemoveUserFromStoreUseCase({required this.repository});

  Future<void> call(String userId, String storeId) async {
    return await repository.removeUserFromStore(userId, storeId);
  }
}
