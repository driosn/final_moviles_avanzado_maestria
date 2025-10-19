import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_remote_datasource.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsRemoteDataSource remoteDataSource;

  ProductsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Product>> getAllProducts() async {
    return await remoteDataSource.getAllProducts();
  }

  @override
  Future<Product> getProductById(String id) async {
    return await remoteDataSource.getProductById(id);
  }

  @override
  Future<Product> createProduct(Product product) async {
    return await remoteDataSource.createProduct(product);
  }

  @override
  Future<Product> updateProduct(Product product) async {
    return await remoteDataSource.updateProduct(product);
  }

  @override
  Future<void> deleteProduct(String id) async {
    return await remoteDataSource.deleteProduct(id);
  }

  @override
  Future<String> uploadImage(String imagePath) async {
    return await remoteDataSource.uploadImage(imagePath);
  }
}
