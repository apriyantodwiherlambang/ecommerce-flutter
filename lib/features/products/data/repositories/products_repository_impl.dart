import 'dart:io';

import 'package:frontend_ecommerce/features/products/domain/entities/product_entities.dart';
import 'package:frontend_ecommerce/features/products/domain/repositories/products_repository.dart';
import '../datasources/products_remote_datasource.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsRemoteDataSource remoteDataSource;

  ProductsRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ProductEntity>> getAllProducts() {
    return remoteDataSource.getAllProducts();
  }

  // Implement uploadProduct juga di sini
  @override
  Future<ProductEntity> uploadProduct({
    required String name,
    required String description,
    required int price,
    required int stock,
    required String categoryId,
    required File imageFile,
  }) {
    return remoteDataSource.uploadProduct(
      name: name,
      description: description,
      price: price,
      stock: stock,
      categoryId: categoryId,
      imageFile: imageFile,
    );
  }
}
