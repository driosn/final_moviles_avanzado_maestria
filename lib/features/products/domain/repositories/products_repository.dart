import '../entities/product.dart';

abstract class ProductsRepository {
  Future<List<Product>> getAllProducts();
  Future<Product> getProductById(String id);
  Future<Product> createProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(String id);
  Future<String> uploadImage(String imagePath);
}
