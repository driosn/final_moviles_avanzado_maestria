import 'package:equatable/equatable.dart';

abstract class StoreAssignmentEvent extends Equatable {
  const StoreAssignmentEvent();

  @override
  List<Object?> get props => [];
}

class LoadStoresAndUsers extends StoreAssignmentEvent {
  const LoadStoresAndUsers();
}

class LoadStoreAssignments extends StoreAssignmentEvent {
  final String storeId;

  const LoadStoreAssignments(this.storeId);

  @override
  List<Object?> get props => [storeId];
}

class AssignUserToStore extends StoreAssignmentEvent {
  final String userId;
  final String storeId;

  const AssignUserToStore({required this.userId, required this.storeId});

  @override
  List<Object?> get props => [userId, storeId];
}

class RemoveUserFromStore extends StoreAssignmentEvent {
  final String userId;
  final String storeId;

  const RemoveUserFromStore({required this.userId, required this.storeId});

  @override
  List<Object?> get props => [userId, storeId];
}
