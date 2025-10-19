import 'package:equatable/equatable.dart';

import '../../domain/entities/store.dart';

abstract class StoresEvent extends Equatable {
  const StoresEvent();

  @override
  List<Object?> get props => [];
}

class LoadStores extends StoresEvent {
  const LoadStores();
}

class CreateStore extends StoresEvent {
  final String name;
  final City city;

  const CreateStore({required this.name, required this.city});

  @override
  List<Object> get props => [name, city];
}

class UpdateStore extends StoresEvent {
  final String id;
  final String name;
  final City city;

  const UpdateStore({required this.id, required this.name, required this.city});

  @override
  List<Object> get props => [id, name, city];
}

class DeleteStore extends StoresEvent {
  final String id;

  const DeleteStore(this.id);

  @override
  List<Object> get props => [id];
}

class ClearStoresError extends StoresEvent {
  const ClearStoresError();
}
