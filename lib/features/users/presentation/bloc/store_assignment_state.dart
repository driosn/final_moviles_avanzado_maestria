import 'package:equatable/equatable.dart';

import '../../../stores/domain/entities/store.dart';
import '../../domain/entities/user.dart';

abstract class StoreAssignmentState extends Equatable {
  const StoreAssignmentState();

  @override
  List<Object?> get props => [];
}

class StoreAssignmentInitial extends StoreAssignmentState {}

class StoreAssignmentLoading extends StoreAssignmentState {}

class StoreAssignmentLoaded extends StoreAssignmentState {
  final List<Store> stores;
  final List<User> assignedUsers;
  final List<User> availableUsers;

  const StoreAssignmentLoaded({required this.stores, required this.assignedUsers, required this.availableUsers});

  @override
  List<Object?> get props => [stores, assignedUsers, availableUsers];
}

class UserAssignedToStore extends StoreAssignmentState {
  final String userId;
  final String storeId;

  const UserAssignedToStore({required this.userId, required this.storeId});

  @override
  List<Object?> get props => [userId, storeId];
}

class UserRemovedFromStore extends StoreAssignmentState {
  final String userId;
  final String storeId;

  const UserRemovedFromStore({required this.userId, required this.storeId});

  @override
  List<Object?> get props => [userId, storeId];
}

class StoreAssignmentError extends StoreAssignmentState {
  final String message;

  const StoreAssignmentError({required this.message});

  @override
  List<Object?> get props => [message];
}
