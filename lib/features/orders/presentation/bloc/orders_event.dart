abstract class OrdersEvent {}

class LoadOrders extends OrdersEvent {}

class LoadOrderById extends OrdersEvent {
  final String orderId;

  LoadOrderById(this.orderId);
}

class CreateOrder extends OrdersEvent {
  final String storeId;
  final Map<String, int> cart;
  final List<dynamic> inventoryItems;

  CreateOrder({required this.storeId, required this.cart, required this.inventoryItems});
}
