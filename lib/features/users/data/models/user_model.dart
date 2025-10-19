import '../../domain/entities/user.dart' as domain;

class UserModel extends domain.User {
  const UserModel({
    required super.id,
    required super.userId,
    required super.email,
    super.name,
    required super.role,
    super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      role: _parseRole(json['role'] as String?),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
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
      'user_id': id, // Cambiado de 'id' a 'user_id'
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

  domain.User toEntity() {
    return domain.User(
      id: id,
      userId: userId,
      email: email,
      name: name,
      role: role,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
