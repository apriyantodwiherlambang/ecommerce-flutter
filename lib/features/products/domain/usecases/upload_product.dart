// products/domain/usecases/upload_product.dart
import '../entities/product_entities.dart';
import '../repositories/products_repository.dart';
import 'dart:io';

class UploadProduct {
  final ProductsRepository repository;

  UploadProduct(this.repository);

  Future<ProductEntity> call({
    required String name,
    required String description,
    required int price,
    required int stock,
    required String categoryId,
    required File imageFile,
  }) {
    return repository.uploadProduct(
      name: name,
      description: description,
      price: price,
      stock: stock,
      categoryId: categoryId,
      imageFile: imageFile,
    );
  }
}
