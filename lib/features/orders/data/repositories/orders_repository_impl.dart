import '../../domain/entities/order.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_datasource.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource remoteDataSource;

  OrdersRepositoryImpl(this.remoteDataSource);

  @override
  Future<Order> createOrder({
    required String storeId,
    required Map<String, int> cart,
    required List<dynamic> inventoryItems,
  }) async {
    final orderModel = await remoteDataSource.createOrder(storeId: storeId, cart: cart, inventoryItems: inventoryItems);
    return orderModel.toEntity();
  }

  @override
  Future<List<Order>> getOrdersByUser() async {
    final orderModels = await remoteDataSource.getOrdersByUser();
    return orderModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Order> getOrderById(String orderId) async {
    final orderModel = await remoteDataSource.getOrderById(orderId);
    return orderModel.toEntity();
  }
}
