import '../entities/product.dart';
import '../repositories/products_repository.dart';

class GetProductByIdUseCase {
  final ProductsRepository repository;

  GetProductByIdUseCase({required this.repository});

  Future<Product> call(String id) async {
    return await repository.getProductById(id);
  }
}
