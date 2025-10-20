import 'order_item.dart';

enum OrderStatus { pending, confirmed, cancelled }

class Order {
  final String id;
  final String userId;
  final String storeId;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> items;

  const Order({
    required this.id,
    required this.userId,
    required this.storeId,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  Order copyWith({
    String? id,
    String? userId,
    String? storeId,
    double? totalAmount,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderItem>? items,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      storeId: storeId ?? this.storeId,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order &&
        other.id == id &&
        other.userId == userId &&
        other.storeId == storeId &&
        other.totalAmount == totalAmount &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.items == items;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        storeId.hashCode ^
        totalAmount.hashCode ^
        status.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        items.hashCode;
  }

  @override
  String toString() {
    return 'Order(id: $id, userId: $userId, storeId: $storeId, totalAmount: $totalAmount, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, items: $items)';
  }
}
