import '../../../stores/domain/entities/store.dart';
import '../repositories/store_assignment_repository.dart';

class GetUserAssignedStoresUseCase {
  final StoreAssignmentRepository repository;

  GetUserAssignedStoresUseCase({required this.repository});

  Future<List<Store>> call() async {
    return await repository.getUserAssignedStores();
  }
}
