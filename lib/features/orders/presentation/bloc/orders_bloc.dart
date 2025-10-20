import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_order_usecase.dart';
import '../../domain/usecases/get_order_by_id_usecase.dart';
import '../../domain/usecases/get_orders_by_user_usecase.dart';
import 'orders_event.dart';
import 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final CreateOrderUseCase createOrderUseCase;
  final GetOrdersByUserUseCase getOrdersByUserUseCase;
  final GetOrderByIdUseCase getOrderByIdUseCase;

  OrdersBloc({
    required this.createOrderUseCase,
    required this.getOrdersByUserUseCase,
    required this.getOrderByIdUseCase,
  }) : super(OrdersInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<LoadOrderById>(_onLoadOrderById);
    on<CreateOrder>(_onCreateOrder);
  }

  Future<void> _onLoadOrders(LoadOrders event, Emitter<OrdersState> emit) async {
    emit(OrdersLoading());
    try {
      final orders = await getOrdersByUserUseCase();
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrdersError('Error al cargar pedidos: $e'));
    }
  }

  Future<void> _onLoadOrderById(LoadOrderById event, Emitter<OrdersState> emit) async {
    emit(OrdersLoading());
    try {
      final order = await getOrderByIdUseCase(event.orderId);
      emit(OrderLoaded(order));
    } catch (e) {
      emit(OrdersError('Error al cargar pedido: $e'));
    }
  }

  Future<void> _onCreateOrder(CreateOrder event, Emitter<OrdersState> emit) async {
    emit(OrdersLoading());
    try {
      final order = await createOrderUseCase(
        storeId: event.storeId,
        cart: event.cart,
        inventoryItems: event.inventoryItems,
      );
      emit(OrderCreated(order));
    } catch (e) {
      emit(OrdersError('Error al crear pedido: $e'));
    }
  }
}
