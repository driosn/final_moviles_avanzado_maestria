import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/stores/data/datasources/stores_remote_datasource.dart';
import '../../features/stores/data/repositories/stores_repository_impl.dart';
import '../../features/stores/domain/repositories/stores_repository.dart';
import '../../features/stores/domain/usecases/create_store_usecase.dart';
import '../../features/stores/domain/usecases/delete_store_usecase.dart';
import '../../features/stores/domain/usecases/get_all_stores_usecase.dart';
import '../../features/stores/domain/usecases/get_store_by_id_usecase.dart';
import '../../features/stores/domain/usecases/update_store_usecase.dart';
import '../../features/stores/presentation/bloc/stores_bloc.dart';
import '../../features/users/data/datasources/store_assignment_remote_datasource.dart';
import '../../features/users/data/repositories/store_assignment_repository_impl.dart';
import '../../features/users/domain/repositories/store_assignment_repository.dart';
import '../../features/users/domain/usecases/assign_user_to_store_usecase.dart';
import '../../features/users/domain/usecases/get_all_stores_usecase.dart' as users;
import '../../features/users/domain/usecases/get_assigned_users_usecase.dart';
import '../../features/users/domain/usecases/get_available_users_usecase.dart';
import '../../features/users/domain/usecases/get_gestor_users_usecase.dart';
import '../../features/users/domain/usecases/remove_user_from_store_usecase.dart';
import '../../features/users/presentation/bloc/store_assignment_bloc.dart';
import '../constants/supabase_config.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Initialize Supabase
  await supabase.Supabase.initialize(url: SupabaseConfig.supabaseUrl, anonKey: SupabaseConfig.supabaseAnonKey);

  // External
  sl.registerLazySingleton<supabase.SupabaseClient>(() => supabase.Supabase.instance.client);

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(supabaseClient: sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl()));

  // Use cases
  sl.registerLazySingleton(() => SignInUseCase(repository: sl()));
  sl.registerLazySingleton(() => SignUpUseCase(repository: sl()));
  sl.registerLazySingleton(() => SignOutUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(repository: sl()));

  // Bloc
  sl.registerFactory(
    () => AuthBloc(signInUseCase: sl(), signUpUseCase: sl(), signOutUseCase: sl(), getCurrentUserUseCase: sl()),
  );

  // Stores Data sources
  sl.registerLazySingleton<StoresRemoteDataSource>(() => StoresRemoteDataSourceImpl(supabaseClient: sl()));

  // Stores Repository
  sl.registerLazySingleton<StoresRepository>(() => StoresRepositoryImpl(remoteDataSource: sl()));

  // Stores Use cases
  sl.registerLazySingleton(() => GetAllStoresUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetStoreByIdUseCase(repository: sl()));
  sl.registerLazySingleton(() => CreateStoreUseCase(repository: sl()));
  sl.registerLazySingleton(() => UpdateStoreUseCase(repository: sl()));
  sl.registerLazySingleton(() => DeleteStoreUseCase(repository: sl()));

  // Stores Bloc
  sl.registerSingleton(
    () => StoresBloc(
      getAllStoresUseCase: sl(),
      createStoreUseCase: sl(),
      updateStoreUseCase: sl(),
      deleteStoreUseCase: sl(),
    ),
  );

  // Store Assignment Data sources
  sl.registerLazySingleton<StoreAssignmentRemoteDataSource>(
    () => StoreAssignmentRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Store Assignment Repository
  sl.registerLazySingleton<StoreAssignmentRepository>(() => StoreAssignmentRepositoryImpl(remoteDataSource: sl()));

  // Store Assignment Use cases
  sl.registerLazySingleton(() => users.GetAllStoresUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetGestorUsersUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetAssignedUsersUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetAvailableUsersUseCase(repository: sl()));
  sl.registerLazySingleton(() => AssignUserToStoreUseCase(repository: sl()));
  sl.registerLazySingleton(() => RemoveUserFromStoreUseCase(repository: sl()));

  // Store Assignment Bloc
  sl.registerFactory(
    () => StoreAssignmentBloc(
      getAllStoresUseCase: sl(),
      getGestorUsersUseCase: sl(),
      getAssignedUsersUseCase: sl(),
      getAvailableUsersUseCase: sl(),
      assignUserToStoreUseCase: sl(),
      removeUserFromStoreUseCase: sl(),
    ),
  );
}
