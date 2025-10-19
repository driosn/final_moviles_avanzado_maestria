import '../entities/product.dart';
import '../repositories/products_repository.dart';

class GetAllProductsUseCase {
  final ProductsRepository repository;

  GetAllProductsUseCase({required this.repository});

  Future<List<Product>> call() async {
    return await repository.getAllProducts();
  }
}
