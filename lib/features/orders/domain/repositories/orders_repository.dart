import '../entities/order.dart';

abstract class OrdersRepository {
  Future<Order> createOrder({
    required String storeId,
    required Map<String, int> cart,
    required List<dynamic> inventoryItems,
  });

  Future<List<Order>> getOrdersByUser();

  Future<Order> getOrderById(String orderId);
}
