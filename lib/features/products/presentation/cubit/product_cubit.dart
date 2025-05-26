import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_ecommerce/features/products/domain/entities/product_entities.dart';
import 'package:frontend_ecommerce/features/products/domain/usecases/fetch_products_usecase.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final FetchProductsUseCase fetchProductsUseCase;

  ProductCubit(this.fetchProductsUseCase) : super(ProductInitial());

  Future<void> fetchProducts() async {
    emit(ProductLoading());
    try {
      final products =
          await fetchProductsUseCase.execute(); // ✅ PERBAIKAN DI SINI
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}
