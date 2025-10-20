import '../entities/order.dart';
import '../repositories/orders_repository.dart';

class CreateOrderUseCase {
  final OrdersRepository repository;

  CreateOrderUseCase(this.repository);

  Future<Order> call({
    required String storeId,
    required Map<String, int> cart,
    required List<dynamic> inventoryItems,
  }) async {
    return await repository.createOrder(storeId: storeId, cart: cart, inventoryItems: inventoryItems);
  }
}
