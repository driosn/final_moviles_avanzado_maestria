import '../entities/user.dart';
import '../repositories/store_assignment_repository.dart';

class GetAssignedUsersUseCase {
  final StoreAssignmentRepository repository;

  GetAssignedUsersUseCase({required this.repository});

  Future<List<User>> call(String storeId) async {
    return await repository.getAssignedUsers(storeId);
  }
}
