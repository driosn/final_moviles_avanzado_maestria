import '../../domain/entities/order.dart';

abstract class OrdersState {}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<Order> orders;

  OrdersLoaded(this.orders);
}

class OrderLoaded extends OrdersState {
  final Order order;

  OrderLoaded(this.order);
}

class OrderCreated extends OrdersState {
  final Order order;

  OrderCreated(this.order);
}

class OrdersError extends OrdersState {
  final String message;

  OrdersError(this.message);
}
