import 'package:equatable/equatable.dart';

class StoreAssignment extends Equatable {
  final String id;
  final String userId;
  final String storeId;
  final DateTime assignedAt;
  final DateTime? updatedAt;

  const StoreAssignment({
    required this.id,
    required this.userId,
    required this.storeId,
    required this.assignedAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, userId, storeId, assignedAt, updatedAt];

  StoreAssignment copyWith({String? id, String? userId, String? storeId, DateTime? assignedAt, DateTime? updatedAt}) {
    return StoreAssignment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      storeId: storeId ?? this.storeId,
      assignedAt: assignedAt ?? this.assignedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
