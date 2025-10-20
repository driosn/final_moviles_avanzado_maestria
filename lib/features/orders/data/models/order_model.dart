import '../../domain/entities/order.dart' as domain;
import 'order_item_model.dart';

class OrderModel extends domain.Order {
  const OrderModel({
    required super.id,
    required super.userId,
    required super.storeId,
    required super.totalAmount,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    required super.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      storeId: json['store_id'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: _parseStatus(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      items:
          (json['order_items'] as List<dynamic>?)
              ?.map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  static domain.OrderStatus _parseStatus(String status) {
    switch (status) {
      case 'pending':
        return domain.OrderStatus.pending;
      case 'confirmed':
        return domain.OrderStatus.confirmed;
      case 'cancelled':
        return domain.OrderStatus.cancelled;
      default:
        return domain.OrderStatus.pending;
    }
  }

  factory OrderModel.fromEntity(domain.Order order) {
    return OrderModel(
      id: order.id,
      userId: order.userId,
      storeId: order.storeId,
      totalAmount: order.totalAmount,
      status: order.status,
      createdAt: order.createdAt,
      updatedAt: order.updatedAt,
      items: order.items.map((item) => OrderItemModel.fromEntity(item)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'store_id': storeId,
      'total_amount': totalAmount,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'order_items': items.map((item) => (item as OrderItemModel).toJson()).toList(),
    };
  }

  domain.Order toEntity() {
    return domain.Order(
      id: id,
      userId: userId,
      storeId: storeId,
      totalAmount: totalAmount,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      items: items,
    );
  }
}
