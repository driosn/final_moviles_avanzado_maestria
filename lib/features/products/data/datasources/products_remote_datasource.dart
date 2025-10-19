import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../domain/entities/product.dart';
import '../models/product_model.dart';

abstract class ProductsRemoteDataSource {
  Future<List<Product>> getAllProducts();
  Future<Product> getProductById(String id);
  Future<Product> createProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(String id);
  Future<String> uploadImage(String imagePath);
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  final supabase.SupabaseClient _supabaseClient;

  ProductsRemoteDataSourceImpl({required supabase.SupabaseClient supabaseClient}) : _supabaseClient = supabaseClient;

  @override
  Future<List<Product>> getAllProducts() async {
    try {
      final response = await _supabaseClient.from('products').select('*').order('created_at', ascending: false);
      return response.map((json) => ProductModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      throw Exception('Error al cargar productos: $e');
    }
  }

  @override
  Future<Product> getProductById(String id) async {
    try {
      final response = await _supabaseClient.from('products').select('*').eq('id', id).single();
      return ProductModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al cargar producto: $e');
    }
  }

  @override
  Future<Product> createProduct(Product product) async {
    try {
      final productModel = ProductModel.fromEntity(product);
      final response = await _supabaseClient.from('products').insert(productModel.toSupabaseJson()).select().single();
      return ProductModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al crear producto: $e');
    }
  }

  @override
  Future<Product> updateProduct(Product product) async {
    try {
      final productModel = ProductModel.fromEntity(product);
      final response = await _supabaseClient
          .from('products')
          .update(productModel.toSupabaseJson())
          .eq('id', product.id)
          .select()
          .single();
      return ProductModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al actualizar producto: $e');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await _supabaseClient.from('products').delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar producto: $e');
    }
  }

  @override
  Future<String> uploadImage(String imagePath) async {
    try {
      final file = File(imagePath);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

      // Subir imagen al bucket 'images'
      await _supabaseClient.storage.from('images').upload(fileName, file);

      // Obtener URL pública de la imagen
      final imageUrl = _supabaseClient.storage.from('images').getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      throw Exception('Error al subir imagen: $e');
    }
  }
}
