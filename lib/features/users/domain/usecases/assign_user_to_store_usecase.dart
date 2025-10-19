import '../repositories/store_assignment_repository.dart';

class AssignUserToStoreUseCase {
  final StoreAssignmentRepository repository;

  AssignUserToStoreUseCase({required this.repository});

  Future<void> call(String userId, String storeId) async {
    return await repository.assignUserToStore(userId, storeId);
  }
}
