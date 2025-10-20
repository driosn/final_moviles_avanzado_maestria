import '../entities/order.dart';
import '../repositories/orders_repository.dart';

class GetOrdersByUserUseCase {
  final OrdersRepository repository;

  GetOrdersByUserUseCase(this.repository);

  Future<List<Order>> call() async {
    return await repository.getOrdersByUser();
  }
}
