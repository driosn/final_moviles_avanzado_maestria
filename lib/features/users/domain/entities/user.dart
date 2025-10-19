import 'package:equatable/equatable.dart';

enum UserRole { admin, gestorTienda, cliente }

class User extends Equatable {
  final String id;
  final String userId;
  final String email;
  final String? name;
  final UserRole role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.userId,
    required this.email,
    this.name,
    required this.role,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, userId, email, name, role, createdAt, updatedAt];

  User copyWith({
    String? id,
    String? userId,
    String? email,
    String? name,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
