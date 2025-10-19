import 'package:equatable/equatable.dart';

import '../../domain/entities/store.dart';

abstract class StoresState extends Equatable {
  const StoresState();

  @override
  List<Object?> get props => [];
}

class StoresInitial extends StoresState {
  const StoresInitial();
}

class StoresLoading extends StoresState {
  const StoresLoading();
}

class StoresLoaded extends StoresState {
  final List<Store> stores;

  const StoresLoaded(this.stores);

  @override
  List<Object> get props => [stores];
}

class StoresError extends StoresState {
  final String message;

  const StoresError(this.message);

  @override
  List<Object> get props => [message];
}

class StoreCreated extends StoresState {
  final Store store;

  const StoreCreated(this.store);

  @override
  List<Object> get props => [store];
}

class StoreUpdated extends StoresState {
  final Store store;

  const StoreUpdated(this.store);

  @override
  List<Object> get props => [store];
}

class StoreDeleted extends StoresState {
  final String storeId;

  const StoreDeleted(this.storeId);

  @override
  List<Object> get props => [storeId];
}
