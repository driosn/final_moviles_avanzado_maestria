import '../entities/product.dart';
import '../repositories/products_repository.dart';

class UpdateProductUseCase {
  final ProductsRepository repository;

  UpdateProductUseCase({required this.repository});

  Future<Product> call(Product product) async {
    return await repository.updateProduct(product);
  }
}
