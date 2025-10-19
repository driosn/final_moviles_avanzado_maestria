import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart' as domain;
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<domain.User> signInWithEmail({required String email, required String password});

  Future<domain.User> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required domain.UserRole role,
  });

  Future<void> signOut();

  Future<domain.User?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final supabase.SupabaseClient _supabaseClient;

  AuthRemoteDataSourceImpl({required supabase.SupabaseClient supabaseClient}) : _supabaseClient = supabaseClient;

  @override
  Future<domain.User> signInWithEmail({required String email, required String password}) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(email: email, password: password);

      if (response.user == null) {
        throw const AuthFailure('Usuario no encontrado');
      }

      // Get user role from user metadata or profile table
      final userRole = await _getUserRole(response.user!.id);

      return UserModel.fromSupabaseUser(response.user!, role: userRole);
    } on supabase.AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw ServerFailure('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<domain.User> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required domain.UserRole role,
  }) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'role': _roleToString(role)},
      );

      if (response.user == null) {
        throw const AuthFailure('Error al crear usuario');
      }

      // Create user profile with role
      await _createUserProfile(userId: response.user!.id, email: email, name: name, role: role);

      return UserModel.fromSupabaseUser(response.user!, role: _roleToString(role));
    } on supabase.AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw ServerFailure('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (e) {
      throw ServerFailure('Error al cerrar sesión: ${e.toString()}');
    }
  }

  @override
  Future<domain.User?> getCurrentUser() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return null;

      final userRole = await _getUserRole(user.id);
      return UserModel.fromSupabaseUser(user, role: userRole);
    } catch (e) {
      throw ServerFailure('Error al obtener usuario actual: ${e.toString()}');
    }
  }

  Future<String> _getUserRole(String userId) async {
    try {
      final response = await _supabaseClient.from('user_profiles').select('role').eq('user_id', userId).single();

      return response['role'] as String? ?? 'cliente';
    } catch (e) {
      // If profile doesn't exist, return default role
      return 'cliente';
    }
  }

  Future<void> _createUserProfile({
    required String userId,
    required String email,
    required String name,
    required domain.UserRole role,
  }) async {
    try {
      await _supabaseClient.from('user_profiles').insert({
        'user_id': userId,
        'email': email,
        'name': name,
        'role': _roleToString(role),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Log error but don't throw to avoid breaking signup flow
      print('Error creating user profile: $e');
    }
  }

  String _roleToString(domain.UserRole role) {
    switch (role) {
      case domain.UserRole.admin:
        return 'admin';
      case domain.UserRole.gestorTienda:
        return 'gestor_tienda';
      case domain.UserRole.cliente:
        return 'cliente';
    }
  }
}
