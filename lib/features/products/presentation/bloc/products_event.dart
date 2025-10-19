import 'package:equatable/equatable.dart';

import '../../domain/entities/product.dart';

abstract class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductsEvent {
  const LoadProducts();
}

class CreateProduct extends ProductsEvent {
  final Product product;

  const CreateProduct({required this.product});

  @override
  List<Object?> get props => [product];
}

class UpdateProduct extends ProductsEvent {
  final Product product;

  const UpdateProduct({required this.product});

  @override
  List<Object?> get props => [product];
}

class DeleteProduct extends ProductsEvent {
  final String productId;

  const DeleteProduct({required this.productId});

  @override
  List<Object?> get props => [productId];
}

class UploadImage extends ProductsEvent {
  final String imagePath;

  const UploadImage({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

class CreateProductWithImage extends ProductsEvent {
  final Product product;
  final String imagePath;

  const CreateProductWithImage({required this.product, required this.imagePath});

  @override
  List<Object?> get props => [product, imagePath];
}

class UpdateProductWithImage extends ProductsEvent {
  final Product product;
  final String imagePath;

  const UpdateProductWithImage({required this.product, required this.imagePath});

  @override
  List<Object?> get props => [product, imagePath];
}
