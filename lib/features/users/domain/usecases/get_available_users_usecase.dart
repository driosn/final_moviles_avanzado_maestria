import '../entities/user.dart';
import '../repositories/store_assignment_repository.dart';

class GetAvailableUsersUseCase {
  final StoreAssignmentRepository repository;

  GetAvailableUsersUseCase({required this.repository});

  Future<List<User>> call(String storeId) async {
    return await repository.getAvailableUsers(storeId);
  }
}
