import '../entities/order.dart';
import '../repositories/orders_repository.dart';

class GetOrderByIdUseCase {
  final OrdersRepository repository;

  GetOrderByIdUseCase(this.repository);

  Future<Order> call(String orderId) async {
    return await repository.getOrderById(orderId);
  }
}
