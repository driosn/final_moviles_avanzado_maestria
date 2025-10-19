import '../entities/user.dart';
import '../repositories/store_assignment_repository.dart';

class GetGestorUsersUseCase {
  final StoreAssignmentRepository repository;

  GetGestorUsersUseCase({required this.repository});

  Future<List<User>> call() async {
    return await repository.getUsersByRole(UserRole.gestorTienda);
  }
}
