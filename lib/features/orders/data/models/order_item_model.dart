import '../../../products/data/models/product_model.dart';
import '../../domain/entities/order_item.dart' as domain;

class OrderItemModel extends domain.OrderItem {
  const OrderItemModel({
    required super.id,
    required super.orderId,
    required super.productId,
    required super.product,
    required super.quantity,
    required super.unitPrice,
    required super.totalPrice,
    required super.createdAt,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      productId: json['product_id'] as String,
      product: ProductModel.fromJson(json['products'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  factory OrderItemModel.fromEntity(domain.OrderItem orderItem) {
    return OrderItemModel(
      id: orderItem.id,
      orderId: orderItem.orderId,
      productId: orderItem.productId,
      product: orderItem.product,
      quantity: orderItem.quantity,
      unitPrice: orderItem.unitPrice,
      totalPrice: orderItem.totalPrice,
      createdAt: orderItem.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'created_at': createdAt.toIso8601String(),
      'products': (product as ProductModel).toJson(),
    };
  }

  domain.OrderItem toEntity() {
    return domain.OrderItem(
      id: id,
      orderId: orderId,
      productId: productId,
      product: product,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      createdAt: createdAt,
    );
  }
}
