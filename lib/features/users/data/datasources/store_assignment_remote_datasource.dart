import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../stores/data/models/store_model.dart';
import '../../../stores/domain/entities/store.dart';
import '../../domain/entities/user.dart';
import '../models/user_model.dart';

abstract class StoreAssignmentRemoteDataSource {
  Future<List<Store>> getAllStores();
  Future<List<User>> getUsersByRole(UserRole role);
  Future<List<User>> getAssignedUsers(String storeId);
  Future<List<User>> getAvailableUsers(String storeId);
  Future<void> assignUserToStore(String userId, String storeId);
  Future<void> removeUserFromStore(String userId, String storeId);
}

class StoreAssignmentRemoteDataSourceImpl implements StoreAssignmentRemoteDataSource {
  final supabase.SupabaseClient _supabaseClient;

  StoreAssignmentRemoteDataSourceImpl({required supabase.SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  @override
  Future<List<Store>> getAllStores() async {
    try {
      final response = await _supabaseClient.from('stores').select('*').order('name');
      return response.map((json) => StoreModel.fromJson(json) as Store).toList();
    } catch (e) {
      throw Exception('Error al cargar tiendas: $e');
    }
  }

  @override
  Future<List<User>> getUsersByRole(UserRole role) async {
    try {
      final roleString = _roleToString(role);
      print('DEBUG: Searching for users with role: $roleString');

      // Primero, vamos a ver todos los usuarios para debug
      final allUsersResponse = await _supabaseClient.from('user_profiles').select('*');
      print('DEBUG: All users in database: $allUsersResponse');

      // Ahora la consulta específica por rol
      final response = await _supabaseClient.from('user_profiles').select('*').eq('role', roleString).order('name');
      print('DEBUG: Users with role $roleString: $response');

      final users = response.map((json) => UserModel.fromJson(json).toEntity()).toList();
      print('DEBUG: Parsed users: ${users.length}');
      return users;
    } catch (e) {
      print('DEBUG: Error in getUsersByRole: $e');
      throw Exception('Error al cargar usuarios: $e');
    }
  }

  @override
  Future<List<User>> getAssignedUsers(String storeId) async {
    try {
      final response = await _supabaseClient
          .from('store_assignments')
          .select('''
            user_profiles!inner(
              id,
              user_id,
              email,
              name,
              role,
              created_at,
              updated_at
            )
          ''')
          .eq('store_id', storeId);

      return response.map((json) => UserModel.fromJson(json['user_profiles']).toEntity()).toList();
    } catch (e) {
      throw Exception('Error al cargar usuarios asignados: $e');
    }
  }

  @override
  Future<List<User>> getAvailableUsers(String storeId) async {
    try {
      // Get all gestor users
      final allGestorUsers = await getUsersByRole(UserRole.gestorTienda);
      print('DEBUG: Total gestor users found: ${allGestorUsers.length}');

      // TEMPORAL: Si no hay gestores, mostrar todos los usuarios no-admin para debug
      if (allGestorUsers.isEmpty) {
        print('DEBUG: No gestor users found, showing all non-admin users for debug');
        final allUsers = await _supabaseClient.from('user_profiles').select('*');
        print('DEBUG: All users for debug: $allUsers');

        // Mostrar usuarios que no sean admin
        final nonAdminUsers = allUsers.where((user) => user['role'] != 'admin').toList();
        print('DEBUG: Non-admin users: $nonAdminUsers');

        // Por ahora, devolver usuarios con rol 'cliente' como gestores temporales
        final tempGestorUsers = nonAdminUsers.map((json) => UserModel.fromJson(json).toEntity()).toList();
        print('DEBUG: Using temp gestor users: ${tempGestorUsers.length}');

        // Get assigned users for this store
        final assignedUsers = await getAssignedUsers(storeId);
        print('DEBUG: Assigned users for store $storeId: ${assignedUsers.length}');

        // Filter out assigned users
        final assignedUserIds = assignedUsers.map((user) => user.id).toSet();
        final availableUsers = tempGestorUsers.where((user) => !assignedUserIds.contains(user.id)).toList();

        print('DEBUG: Available users (temp): ${availableUsers.length}');
        return availableUsers;
      }

      // Get assigned users for this store
      final assignedUsers = await getAssignedUsers(storeId);
      print('DEBUG: Assigned users for store $storeId: ${assignedUsers.length}');

      // Filter out assigned users
      final assignedUserIds = assignedUsers.map((user) => user.id).toSet();
      final availableUsers = allGestorUsers.where((user) => !assignedUserIds.contains(user.id)).toList();

      print('DEBUG: Available users: ${availableUsers.length}');
      return availableUsers;
    } catch (e) {
      print('DEBUG: Error in getAvailableUsers: $e');
      throw Exception('Error al cargar usuarios disponibles: $e');
    }
  }

  @override
  Future<void> assignUserToStore(String userId, String storeId) async {
    try {
      print('DEBUG: Attempting to assign user $userId to store $storeId');

      // Verificar que el usuario existe en user_profiles
      final userCheck = await _supabaseClient.from('user_profiles').select('user_id').eq('user_id', userId);
      print('DEBUG: User check result: $userCheck');

      if (userCheck.isEmpty) {
        throw Exception('Usuario con ID $userId no encontrado en user_profiles');
      }

      // Verificar que la tienda existe
      final storeCheck = await _supabaseClient.from('stores').select('id').eq('id', storeId);
      print('DEBUG: Store check result: $storeCheck');

      if (storeCheck.isEmpty) {
        throw Exception('Tienda con ID $storeId no encontrada en stores');
      }

      await _supabaseClient.from('store_assignments').insert({
        'user_id': userId,
        'store_id': storeId,
        'assigned_at': DateTime.now().toIso8601String(),
      });

      print('DEBUG: Successfully assigned user $userId to store $storeId');
    } catch (e) {
      print('DEBUG: Error in assignUserToStore: $e');
      throw Exception('Error al asignar usuario a tienda: $e');
    }
  }

  @override
  Future<void> removeUserFromStore(String userId, String storeId) async {
    try {
      print('DEBUG: Attempting to remove user $userId from store $storeId');

      await _supabaseClient.from('store_assignments').delete().eq('user_id', userId).eq('store_id', storeId);

      print('DEBUG: Successfully removed user $userId from store $storeId');
    } catch (e) {
      print('DEBUG: Error in removeUserFromStore: $e');
      throw Exception('Error al remover usuario de tienda: $e');
    }
  }

  String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'admin';
      case UserRole.gestorTienda:
        return 'gestor_tienda';
      case UserRole.cliente:
        return 'cliente';
    }
  }
}
