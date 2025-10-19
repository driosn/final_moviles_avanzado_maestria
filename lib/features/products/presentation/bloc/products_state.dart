import 'package:equatable/equatable.dart';

import '../../domain/entities/product.dart';

abstract class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object?> get props => [];
}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final List<Product> products;

  const ProductsLoaded({required this.products});

  @override
  List<Object?> get props => [products];
}

class ProductCreated extends ProductsState {
  final Product product;

  const ProductCreated({required this.product});

  @override
  List<Object?> get props => [product];
}

class ProductUpdated extends ProductsState {
  final Product product;

  const ProductUpdated({required this.product});

  @override
  List<Object?> get props => [product];
}

class ProductDeleted extends ProductsState {
  final String productId;

  const ProductDeleted({required this.productId});

  @override
  List<Object?> get props => [productId];
}

class ImageUploaded extends ProductsState {
  final String imageUrl;

  const ImageUploaded({required this.imageUrl});

  @override
  List<Object?> get props => [imageUrl];
}

class ProductsError extends ProductsState {
  final String message;

  const ProductsError({required this.message});

  @override
  List<Object?> get props => [message];
}
