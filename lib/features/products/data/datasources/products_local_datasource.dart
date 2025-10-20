// import 'package:drift/drift.dart';

// import '../../../../core/database/app_database.dart';
// import '../../domain/entities/product.dart';
// import '../models/product_model.dart';

// abstract class ProductsLocalDataSource {
//   Future<List<Product>> getAllProducts();
//   Future<Product?> getProductById(String id);
//   Future<void> insertProduct(Product product);
//   Future<void> insertProducts(List<Product> products);
//   Future<void> updateProduct(Product product);
//   Future<void> deleteProduct(String id);
//   Future<void> clearProducts();
// }

// class ProductsLocalDataSourceImpl implements ProductsLocalDataSource {
//   final AppDatabase _database;

//   ProductsLocalDataSourceImpl({required AppDatabase database}) : _database = database;

//   @override
//   Future<List<Product>> getAllProducts() async {
//     try {
//       print('DEBUG: ProductsLocalDataSource.getAllProducts() called');
//       final productsData = await _database.getAllProducts();
//       print('DEBUG: Found ${productsData.length} products in local database');
//       final products = productsData.map((data) => _convertToProduct(data)).toList();
//       print('DEBUG: Converted to ${products.length} Product entities');
//       return products;
//     } catch (e) {
//       print('DEBUG: Error in ProductsLocalDataSource.getAllProducts(): $e');
//       throw Exception('Error al obtener productos locales: ${e.toString()}');
//     }
//   }

//   @override
//   Future<Product?> getProductById(String id) async {
//     try {
//       final productData = await _database.getProductById(id);
//       if (productData == null) return null;
//       return _convertToProduct(productData);
//     } catch (e) {
//       throw Exception('Error al obtener producto local: ${e.toString()}');
//     }
//   }

//   @override
//   Future<void> insertProduct(Product product) async {
//     try {
//       final productCompanion = _convertToProductCompanion(product);
//       await _database.insertProduct(productCompanion);
//     } catch (e) {
//       throw Exception('Error al insertar producto local: ${e.toString()}');
//     }
//   }

//   @override
//   Future<void> insertProducts(List<Product> products) async {
//     try {
//       final productCompanions = products.map((product) => _convertToProductCompanion(product)).toList();
//       await _database.insertProducts(productCompanions);
//     } catch (e) {
//       throw Exception('Error al insertar productos locales: ${e.toString()}');
//     }
//   }

//   @override
//   Future<void> updateProduct(Product product) async {
//     try {
//       final productCompanion = _convertToProductCompanion(product);
//       await _database.insertProduct(productCompanion); // insertOrReplace mode
//     } catch (e) {
//       throw Exception('Error al actualizar producto local: ${e.toString()}');
//     }
//   }

//   @override
//   Future<void> deleteProduct(String id) async {
//     try {
//       await _database.executeCustomUpdate('DELETE FROM products_table WHERE id = ?', [id]);
//     } catch (e) {
//       throw Exception('Error al eliminar producto local: ${e.toString()}');
//     }
//   }

//   @override
//   Future<void> clearProducts() async {
//     try {
//       await _database.executeCustomUpdate('DELETE FROM products_table', []);
//     } catch (e) {
//       throw Exception('Error al limpiar productos locales: ${e.toString()}');
//     }
//   }

//   Product _convertToProduct(ProductsTableData data) {
//     return ProductModel(
//       id: data.id,
//       name: data.name,
//       price: data.price,
//       category: data.category,
//       imageUrl: data.imageUrl,
//       createdAt: data.createdAt,
//       updatedAt: data.updatedAt,
//     );
//   }

//   ProductsTableCompanion _convertToProductCompanion(Product product) {
//     return ProductsTableCompanion(
//       id: Value(product.id),
//       name: Value(product.name),
//       price: Value(product.price),
//       category: Value(product.category),
//       imageUrl: Value(product.imageUrl),
//       createdAt: Value(product.createdAt),
//       updatedAt: Value(product.updatedAt),
//       lastSyncedAt: Value(DateTime.now()),
//     );
//   }
// }
