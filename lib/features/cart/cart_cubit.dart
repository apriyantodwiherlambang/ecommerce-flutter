import 'package:flutter_bloc/flutter_bloc.dart';
import './cart_model.dart';
import './cart_remote_datasource.dart';

abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItemModel> items;

  CartLoaded(this.items);
}

class CartError extends CartState {
  final String message;

  CartError(this.message);
}

class CartCubit extends Cubit<CartState> {
  final CartRemoteDatasource datasource;

  CartCubit(this.datasource) : super(CartInitial());

  Future<void> fetchCart() async {
    emit(CartLoading());
    try {
      final items = await datasource.getCart();
      emit(CartLoaded(items));
    } catch (e) {
      emit(CartError('Gagal memuat keranjang: $e'));
    }
  }

  Future<void> addToCart(String productId, int quantity) async {
    emit(CartLoading());
    try {
      await datasource.addToCart(productId, quantity);
      await fetchCart();
    } catch (e) {
      emit(CartError('Gagal menambahkan ke keranjang: $e'));
    }
  }

  Future<void> removeItem(String itemId) async {
    emit(CartLoading());
    try {
      await datasource.removeFromCart(itemId);
      await fetchCart();
    } catch (e) {
      emit(CartError('Gagal menghapus item: $e'));
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    emit(CartLoading());
    try {
      await datasource.updateQuantity(itemId, quantity);
      await fetchCart();
    } catch (e) {
      emit(CartError('Gagal memperbarui jumlah: $e'));
    }
  }

  Future<void> clearCart() async {
    emit(CartLoading());
    try {
      await datasource.clearCart();
      await fetchCart();
    } catch (e) {
      emit(CartError('Gagal mengosongkan keranjang: $e'));
    }
  }

  // Reset state lokal tanpa memanggil API, misalnya saat logout
  void clearCartState() {
    emit(CartInitial());
  }
}
