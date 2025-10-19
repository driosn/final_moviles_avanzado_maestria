import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_product_usecase.dart';
import '../../domain/usecases/delete_product_usecase.dart';
import '../../domain/usecases/get_all_products_usecase.dart';
import '../../domain/usecases/get_product_by_id_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';
import '../../domain/usecases/upload_image_usecase.dart';
import 'products_event.dart';
import 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final GetAllProductsUseCase getAllProductsUseCase;
  final GetProductByIdUseCase getProductByIdUseCase;
  final CreateProductUseCase createProductUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;
  final UploadImageUseCase uploadImageUseCase;

  ProductsBloc({
    required this.getAllProductsUseCase,
    required this.getProductByIdUseCase,
    required this.createProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
    required this.uploadImageUseCase,
  }) : super(ProductsInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<CreateProduct>(_onCreateProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
    on<UploadImage>(_onUploadImage);
    on<CreateProductWithImage>(_onCreateProductWithImage);
    on<UpdateProductWithImage>(_onUpdateProductWithImage);
  }

  Future<void> _onLoadProducts(LoadProducts event, Emitter<ProductsState> emit) async {
    emit(ProductsLoading());
    try {
      final products = await getAllProductsUseCase();
      emit(ProductsLoaded(products: products));
    } catch (e) {
      emit(ProductsError(message: e.toString()));
    }
  }

  Future<void> _onCreateProduct(CreateProduct event, Emitter<ProductsState> emit) async {
    try {
      final product = await createProductUseCase(event.product);
      emit(ProductCreated(product: product));
      // Recargar la lista de productos
      add(const LoadProducts());
    } catch (e) {
      emit(ProductsError(message: e.toString()));
    }
  }

  Future<void> _onUpdateProduct(UpdateProduct event, Emitter<ProductsState> emit) async {
    try {
      final product = await updateProductUseCase(event.product);
      emit(ProductUpdated(product: product));
      // Recargar la lista de productos
      add(const LoadProducts());
    } catch (e) {
      emit(ProductsError(message: e.toString()));
    }
  }

  Future<void> _onDeleteProduct(DeleteProduct event, Emitter<ProductsState> emit) async {
    try {
      await deleteProductUseCase(event.productId);
      emit(ProductDeleted(productId: event.productId));
      // Recargar la lista de productos
      add(const LoadProducts());
    } catch (e) {
      emit(ProductsError(message: e.toString()));
    }
  }

  Future<void> _onUploadImage(UploadImage event, Emitter<ProductsState> emit) async {
    try {
      final imageUrl = await uploadImageUseCase(event.imagePath);
      emit(ImageUploaded(imageUrl: imageUrl));
    } catch (e) {
      emit(ProductsError(message: e.toString()));
    }
  }

  Future<void> _onCreateProductWithImage(CreateProductWithImage event, Emitter<ProductsState> emit) async {
    emit(ProductsLoading());
    try {
      // Primero subir la imagen
      final imageUrl = await uploadImageUseCase(event.imagePath);

      // Crear el producto con la URL de la imagen
      final productWithImage = event.product.copyWith(imageUrl: imageUrl);
      final createdProduct = await createProductUseCase(productWithImage);

      emit(ProductCreated(product: createdProduct));
      // Recargar la lista de productos
      add(const LoadProducts());
    } catch (e) {
      emit(ProductsError(message: e.toString()));
    }
  }

  Future<void> _onUpdateProductWithImage(UpdateProductWithImage event, Emitter<ProductsState> emit) async {
    emit(ProductsLoading());
    try {
      // Primero subir la imagen
      final imageUrl = await uploadImageUseCase(event.imagePath);

      // Actualizar el producto con la nueva URL de la imagen
      final productWithImage = event.product.copyWith(imageUrl: imageUrl);
      final updatedProduct = await updateProductUseCase(productWithImage);

      emit(ProductUpdated(product: updatedProduct));
      // Recargar la lista de productos
      add(const LoadProducts());
    } catch (e) {
      emit(ProductsError(message: e.toString()));
    }
  }
}
