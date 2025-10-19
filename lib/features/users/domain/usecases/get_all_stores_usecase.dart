import '../../../stores/domain/entities/store.dart';
import '../repositories/store_assignment_repository.dart';

class GetAllStoresUseCase {
  final StoreAssignmentRepository repository;

  GetAllStoresUseCase({required this.repository});

  Future<List<Store>> call() async {
    return await repository.getAllStores();
  }
}
