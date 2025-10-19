import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/assign_user_to_store_usecase.dart';
import '../../domain/usecases/get_all_stores_usecase.dart';
import '../../domain/usecases/get_assigned_users_usecase.dart';
import '../../domain/usecases/get_available_users_usecase.dart';
import '../../domain/usecases/get_gestor_users_usecase.dart';
import '../../domain/usecases/remove_user_from_store_usecase.dart';
import 'store_assignment_event.dart';
import 'store_assignment_state.dart';

class StoreAssignmentBloc extends Bloc<StoreAssignmentEvent, StoreAssignmentState> {
  final GetAllStoresUseCase getAllStoresUseCase;
  final GetGestorUsersUseCase getGestorUsersUseCase;
  final GetAssignedUsersUseCase getAssignedUsersUseCase;
  final GetAvailableUsersUseCase getAvailableUsersUseCase;
  final AssignUserToStoreUseCase assignUserToStoreUseCase;
  final RemoveUserFromStoreUseCase removeUserFromStoreUseCase;

  StoreAssignmentBloc({
    required this.getAllStoresUseCase,
    required this.getGestorUsersUseCase,
    required this.getAssignedUsersUseCase,
    required this.getAvailableUsersUseCase,
    required this.assignUserToStoreUseCase,
    required this.removeUserFromStoreUseCase,
  }) : super(StoreAssignmentInitial()) {
    on<LoadStoresAndUsers>(_onLoadStoresAndUsers);
    on<LoadStoreAssignments>(_onLoadStoreAssignments);
    on<AssignUserToStore>(_onAssignUserToStore);
    on<RemoveUserFromStore>(_onRemoveUserFromStore);
  }

  Future<void> _onLoadStoresAndUsers(LoadStoresAndUsers event, Emitter<StoreAssignmentState> emit) async {
    emit(StoreAssignmentLoading());
    try {
      final stores = await getAllStoresUseCase();
      emit(StoreAssignmentLoaded(stores: stores, assignedUsers: [], availableUsers: []));
    } catch (e) {
      emit(StoreAssignmentError(message: e.toString()));
    }
  }

  Future<void> _onLoadStoreAssignments(LoadStoreAssignments event, Emitter<StoreAssignmentState> emit) async {
    if (state is! StoreAssignmentLoaded) return;

    final currentState = state as StoreAssignmentLoaded;
    emit(StoreAssignmentLoading());

    try {
      final assignedUsers = await getAssignedUsersUseCase(event.storeId);
      final availableUsers = await getAvailableUsersUseCase(event.storeId);

      emit(
        StoreAssignmentLoaded(
          stores: currentState.stores,
          assignedUsers: assignedUsers,
          availableUsers: availableUsers,
        ),
      );
    } catch (e) {
      emit(StoreAssignmentError(message: e.toString()));
    }
  }

  Future<void> _onAssignUserToStore(AssignUserToStore event, Emitter<StoreAssignmentState> emit) async {
    try {
      await assignUserToStoreUseCase(event.userId, event.storeId);
      emit(UserAssignedToStore(userId: event.userId, storeId: event.storeId));

      // Reload assignments
      add(LoadStoreAssignments(event.storeId));
    } catch (e) {
      emit(StoreAssignmentError(message: e.toString()));
    }
  }

  Future<void> _onRemoveUserFromStore(RemoveUserFromStore event, Emitter<StoreAssignmentState> emit) async {
    try {
      await removeUserFromStoreUseCase(event.userId, event.storeId);
      emit(UserRemovedFromStore(userId: event.userId, storeId: event.storeId));

      // Reload assignments
      add(LoadStoreAssignments(event.storeId));
    } catch (e) {
      emit(StoreAssignmentError(message: e.toString()));
    }
  }
}
