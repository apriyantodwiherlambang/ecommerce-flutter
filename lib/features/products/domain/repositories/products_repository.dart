// products/domain/repositories/products_repository.dart
import '../entities/product_entities.dart';
import 'dart:io';

abstract class ProductsRepository {
  Future<ProductEntity> uploadProduct({
    required String name,
    required String description,
    required int price,
    required int stock,
    required String categoryId,
    required File imageFile,
  });

  Future<List<ProductEntity>> getAllProducts(); // <== Tambahkan method ini
}
