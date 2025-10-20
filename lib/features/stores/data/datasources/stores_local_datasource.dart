// import 'package:drift/drift.dart';

// import '../../../../core/database/app_database.dart';
// import '../../domain/entities/store.dart' as domain;
// import '../models/store_model.dart';

// abstract class StoresLocalDataSource {
//   Future<List<domain.Store>> getAllStores();
//   Future<domain.Store?> getStoreById(String id);
//   Future<void> insertStore(domain.Store store);
//   Future<void> insertStores(List<domain.Store> stores);
//   Future<void> updateStore(domain.Store store);
//   Future<void> deleteStore(String id);
//   Future<void> clearStores();
// }

// class StoresLocalDataSourceImpl implements StoresLocalDataSource {
//   final AppDatabase _database;

//   StoresLocalDataSourceImpl({required AppDatabase database}) : _database = database;

//   @override
//   Future<List<domain.Store>> getAllStores() async {
//     try {
//       final storesData = await _database.getAllStores();
//       return storesData.map((data) => _convertToStore(data)).toList();
//     } catch (e) {
//       throw Exception('Error al obtener tiendas locales: ${e.toString()}');
//     }
//   }

//   @override
//   Future<domain.Store?> getStoreById(String id) async {
//     try {
//       final storeData = await _database.getStoreById(id);
//       if (storeData == null) return null;
//       return _convertToStore(storeData);
//     } catch (e) {
//       throw Exception('Error al obtener tienda local: ${e.toString()}');
//     }
//   }

//   @override
//   Future<void> insertStore(domain.Store store) async {
//     try {
//       final storeCompanion = _convertToStoreCompanion(store);
//       await _database.insertStore(storeCompanion);
//     } catch (e) {
//       throw Exception('Error al insertar tienda local: ${e.toString()}');
//     }
//   }

//   @override
//   Future<void> insertStores(List<domain.Store> stores) async {
//     try {
//       final storeCompanions = stores.map((store) => _convertToStoreCompanion(store)).toList();
//       await _database.insertStores(storeCompanions);
//     } catch (e) {
//       throw Exception('Error al insertar tiendas locales: ${e.toString()}');
//     }
//   }

//   @override
//   Future<void> updateStore(domain.Store store) async {
//     try {
//       final storeCompanion = _convertToStoreCompanion(store);
//       await _database.insertStore(storeCompanion); // insertOrReplace mode
//     } catch (e) {
//       throw Exception('Error al actualizar tienda local: ${e.toString()}');
//     }
//   }

//   @override
//   Future<void> deleteStore(String id) async {
//     try {
//       await _database.executeCustomUpdate('DELETE FROM stores_table WHERE id = ?', [id]);
//     } catch (e) {
//       throw Exception('Error al eliminar tienda local: ${e.toString()}');
//     }
//   }

//   @override
//   Future<void> clearStores() async {
//     try {
//       await _database.executeCustomUpdate('DELETE FROM stores_table', []);
//     } catch (e) {
//       throw Exception('Error al limpiar tiendas locales: ${e.toString()}');
//     }
//   }

//   domain.Store _convertToStore(StoresTableData data) {
//     return StoreModel(
//       id: data.id,
//       name: data.name,
//       city: _parseCityFromAddress(data.address), // Parse city from address
//       createdAt: data.createdAt,
//       updatedAt: data.updatedAt,
//     );
//   }

//   StoresTableCompanion _convertToStoreCompanion(domain.Store store) {
//     return StoresTableCompanion(
//       id: Value(store.id),
//       name: Value(store.name),
//       address: Value(_cityToAddress(store.city)), // Convert city to address
//       phone: const Value(''), // Default empty phone
//       createdAt: Value(store.createdAt),
//       updatedAt: Value(store.updatedAt),
//       lastSyncedAt: Value(DateTime.now()),
//     );
//   }

//   // Helper method to parse city from address field
//   domain.City _parseCityFromAddress(String address) {
//     final addressLower = address.toLowerCase();
//     if (addressLower.contains('la paz') || addressLower.contains('lapaz')) {
//       return domain.City.laPaz;
//     } else if (addressLower.contains('cochabamba')) {
//       return domain.City.cochabamba;
//     } else if (addressLower.contains('santa cruz') || addressLower.contains('santacruz')) {
//       return domain.City.santaCruz;
//     }
//     return domain.City.laPaz; // Default city
//   }

//   // Helper method to convert city to address
//   String _cityToAddress(domain.City city) {
//     switch (city) {
//       case domain.City.laPaz:
//         return 'La Paz, Bolivia';
//       case domain.City.cochabamba:
//         return 'Cochabamba, Bolivia';
//       case domain.City.santaCruz:
//         return 'Santa Cruz, Bolivia';
//     }
//   }
// }
