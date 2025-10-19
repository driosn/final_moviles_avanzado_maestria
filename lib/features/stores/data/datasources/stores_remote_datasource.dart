import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/errors/failures.dart';
import '../../domain/entities/store.dart' as domain;
import '../models/store_model.dart';

abstract class StoresRemoteDataSource {
  Future<List<domain.Store>> getAllStores();
  Future<domain.Store> getStoreById(String id);
  Future<domain.Store> createStore({required String name, required domain.City city});
  Future<domain.Store> updateStore({required String id, required String name, required domain.City city});
  Future<void> deleteStore(String id);
}

class StoresRemoteDataSourceImpl implements StoresRemoteDataSource {
  final supabase.SupabaseClient _supabaseClient;

  StoresRemoteDataSourceImpl({required supabase.SupabaseClient supabaseClient}) : _supabaseClient = supabaseClient;

  @override
  Future<List<domain.Store>> getAllStores() async {
    try {
      final response = await _supabaseClient.from('stores').select().order('created_at', ascending: false);

      return (response as List).map((data) => StoreModel.fromSupabase(data as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerFailure('Error al obtener tiendas: ${e.toString()}');
    }
  }

  @override
  Future<domain.Store> getStoreById(String id) async {
    try {
      final response = await _supabaseClient.from('stores').select().eq('id', id).single();

      return StoreModel.fromSupabase(response);
    } catch (e) {
      throw ServerFailure('Error al obtener tienda: ${e.toString()}');
    }
  }

  @override
  Future<domain.Store> createStore({required String name, required domain.City city}) async {
    try {
      final storeData = {
        'name': name,
        'city': _cityToString(city),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabaseClient.from('stores').insert(storeData).select().single();

      return StoreModel.fromSupabase(response);
    } catch (e) {
      throw ServerFailure('Error al crear tienda: ${e.toString()}');
    }
  }

  @override
  Future<domain.Store> updateStore({required String id, required String name, required domain.City city}) async {
    try {
      final storeData = {'name': name, 'city': _cityToString(city), 'updated_at': DateTime.now().toIso8601String()};

      final response = await _supabaseClient.from('stores').update(storeData).eq('id', id).select().single();

      return StoreModel.fromSupabase(response);
    } catch (e) {
      throw ServerFailure('Error al actualizar tienda: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteStore(String id) async {
    try {
      await _supabaseClient.from('stores').delete().eq('id', id);
    } catch (e) {
      throw ServerFailure('Error al eliminar tienda: ${e.toString()}');
    }
  }

  String _cityToString(domain.City city) {
    switch (city) {
      case domain.City.laPaz:
        return 'la_paz';
      case domain.City.cochabamba:
        return 'cochabamba';
      case domain.City.santaCruz:
        return 'santa_cruz';
    }
  }
}
