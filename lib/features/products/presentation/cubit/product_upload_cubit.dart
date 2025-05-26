import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_ecommerce/features/products/domain/entities/product_entities.dart';
import 'package:frontend_ecommerce/features/products/domain/usecases/upload_product.dart';
import 'package:frontend_ecommerce/features/products/domain/usecases/fetch_products_usecase.dart';
import 'dart:io';

import 'product_upload_state.dart'; // hanya untuk upload states
import 'product_state.dart'; // untuk product list states

class ProductUploadCubit extends Cubit<ProductUploadState> {
  final UploadProduct uploadProduct;

  ProductUploadCubit(this.uploadProduct) : super(ProductUploadInitial());

  Future<void> upload({
    required String name,
    required String description,
    required int price,
    required int stock,
    required String categoryId,
    required File imageFile,
  }) async {
    emit(ProductUploadLoading());
    try {
      final product = await uploadProduct(
        name: name,
        description: description,
        price: price,
        stock: stock,
        categoryId: categoryId,
        imageFile: imageFile,
      );
      emit(ProductUploadSuccess(product));
    } catch (e) {
      emit(ProductUploadFailure(e.toString()));
    }
  }
}

class ProductCubit extends Cubit<ProductState> {
  final FetchProductsUseCase fetchProductsUseCase;

  ProductCubit({required this.fetchProductsUseCase}) : super(ProductInitial());

  Future<void> fetchProducts() async {
    emit(ProductLoading());
    try {
      final products = await fetchProductsUseCase.execute();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError('Gagal mengambil data produk: $e'));
    }
  }
}
