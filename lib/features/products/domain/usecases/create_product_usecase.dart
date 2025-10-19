import '../entities/product.dart';
import '../repositories/products_repository.dart';

class CreateProductUseCase {
  final ProductsRepository repository;

  CreateProductUseCase({required this.repository});

  Future<Product> call(Product product) async {
    return await repository.createProduct(product);
  }
}
