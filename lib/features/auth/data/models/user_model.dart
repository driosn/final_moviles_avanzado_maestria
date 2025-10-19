import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../domain/entities/user.dart' as domain;

class UserModel extends domain.User {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    required super.role,
    super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      role: _parseRole(json['role'] as String?),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  factory UserModel.fromSupabaseUser(supabase.User supabaseUser, {String? role}) {
    return UserModel(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      name: supabaseUser.userMetadata?['name'] as String?,
      role: _parseRole(role),
      createdAt: supabaseUser.createdAt != null ? DateTime.parse(supabaseUser.createdAt) : null,
      updatedAt: supabaseUser.updatedAt != null ? DateTime.parse(supabaseUser.updatedAt!) : null,
    );
  }

  static domain.UserRole _parseRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return domain.UserRole.admin;
      case 'gestor_tienda':
      case 'gestortienda':
        return domain.UserRole.gestorTienda;
      case 'cliente':
        return domain.UserRole.cliente;
      default:
        return domain.UserRole.cliente; // Default role
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': _roleToString(role),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
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
