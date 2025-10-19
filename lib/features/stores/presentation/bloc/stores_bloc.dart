import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_store_usecase.dart';
import '../../domain/usecases/delete_store_usecase.dart';
import '../../domain/usecases/get_all_stores_usecase.dart';
import '../../domain/usecases/update_store_usecase.dart';
import 'stores_event.dart';
import 'stores_state.dart';

class StoresBloc extends Bloc<StoresEvent, StoresState> {
  final GetAllStoresUseCase _getAllStoresUseCase;
  final CreateStoreUseCase _createStoreUseCase;
  final UpdateStoreUseCase _updateStoreUseCase;
  final DeleteStoreUseCase _deleteStoreUseCase;

  StoresBloc({
    required GetAllStoresUseCase getAllStoresUseCase,
    required CreateStoreUseCase createStoreUseCase,
    required UpdateStoreUseCase updateStoreUseCase,
    required DeleteStoreUseCase deleteStoreUseCase,
  }) : _getAllStoresUseCase = getAllStoresUseCase,
       _createStoreUseCase = createStoreUseCase,
       _updateStoreUseCase = updateStoreUseCase,
       _deleteStoreUseCase = deleteStoreUseCase,
       super(const StoresInitial()) {
    on<LoadStores>(_onLoadStores);
    on<CreateStore>(_onCreateStore);
    on<UpdateStore>(_onUpdateStore);
    on<DeleteStore>(_onDeleteStore);
    on<ClearStoresError>(_onClearStoresError);
  }

  Future<void> _onLoadStores(LoadStores event, Emitter<StoresState> emit) async {
    emit(const StoresLoading());

    final result = await _getAllStoresUseCase();

    result.fold((failure) => emit(StoresError(failure.message)), (stores) => emit(StoresLoaded(stores)));
  }

  Future<void> _onCreateStore(CreateStore event, Emitter<StoresState> emit) async {
    emit(const StoresLoading());

    final result = await _createStoreUseCase(name: event.name, city: event.city);

    result.fold((failure) => emit(StoresError(failure.message)), (store) {
      emit(StoreCreated(store));
      // Reload stores to show the new one
      add(const LoadStores());
    });
  }

  Future<void> _onUpdateStore(UpdateStore event, Emitter<StoresState> emit) async {
    emit(const StoresLoading());

    final result = await _updateStoreUseCase(id: event.id, name: event.name, city: event.city);

    result.fold((failure) => emit(StoresError(failure.message)), (store) {
      emit(StoreUpdated(store));
      // Reload stores to show the updated one
      add(const LoadStores());
    });
  }

  Future<void> _onDeleteStore(DeleteStore event, Emitter<StoresState> emit) async {
    emit(const StoresLoading());

    final result = await _deleteStoreUseCase(event.id);

    result.fold((failure) => emit(StoresError(failure.message)), (_) {
      emit(StoreDeleted(event.id));
      // Reload stores to remove the deleted one
      add(const LoadStores());
    });
  }

  void _onClearStoresError(ClearStoresError event, Emitter<StoresState> emit) {
    if (state is StoresLoaded) {
      emit(StoresLoaded((state as StoresLoaded).stores));
    } else {
      emit(const StoresInitial());
    }
  }
}
