// features/products/domain/usecases/fetch_products_usecase.dart

import 'package:frontend_ecommerce/features/products/domain/entities/product_entities.dart';
import '../../domain/repositories/products_repository.dart';

class FetchProductsUseCase {
  final ProductsRepository repository;

  FetchProductsUseCase(this.repository);

  Future<List<ProductEntity>> execute() async {
    return await repository.getAllProducts();
  }
}
