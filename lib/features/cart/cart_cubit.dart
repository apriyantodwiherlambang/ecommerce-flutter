// lib/features/cart/cart_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart'; // Import equatable
import './cart_model.dart';
import './cart_remote_datasource.dart';

// Pastikan semua state extend Equatable
abstract class CartState extends Equatable {
  const CartState(); // Tambahkan const constructor
  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {
  const CartInitial(); // Tambahkan const constructor
}

class CartLoading extends CartState {
  const CartLoading(); // Tambahkan const constructor
}

class CartLoaded extends CartState {
  final List<CartItemModel> items;

  // Penting: Buat salinan baru dari list saat memancarkan CartLoaded
  // Ini memastikan Bloc mendeteksi perubahan state jika item dalam list berubah.
  const CartLoaded(
      this.items); // Constructor sudah benar jika items adalah List<CartItemModel> baru.
  // Jika tidak, bisa pakai: `CartLoaded(List<CartItemModel> items) : this.items = List.from(items);`
  // Tapi karena `datasource.getCart()` mengembalikan list baru setiap kali, ini OK.

  @override
  List<Object?> get props => [items]; // Bandingkan list itu sendiri.
}

class CartError extends CartState {
  final String message;

  const CartError(this.message); // Tambahkan const constructor

  @override
  List<Object?> get props => [message];
}

class CartCubit extends Cubit<CartState> {
  final CartRemoteDatasource datasource;

  CartCubit(this.datasource)
      : super(const CartInitial()); // Gunakan const CartInitial

  Future<void> fetchCart() async {
    print('CartCubit: fetchCart() called'); // Debugging
    emit(const CartLoading()); // Gunakan const CartLoading
    try {
      final items = await datasource.getCart();
      print('CartCubit: Fetched ${items.length} items.'); // Debugging
      // Pastikan `items` yang dipancarkan adalah list baru.
      // Karena `datasource.getCart()` membuat list baru, `emit(CartLoaded(items))` sudah cukup.
      // Jika tidak yakin, gunakan `emit(CartLoaded(List.from(items)));`
      emit(CartLoaded(items));
    } catch (e) {
      print('CartCubit: Error fetching cart: $e'); // Debugging
      emit(CartError('Gagal memuat keranjang: $e'));
    }
  }

  Future<void> addToCart(String productId, int quantity) async {
    print('CartCubit: addToCart($productId, $quantity) called'); // Debugging
    emit(const CartLoading());
    try {
      await datasource.addToCart(productId, quantity);
      print('CartCubit: Product added, refetching cart...'); // Debugging
      await fetchCart(); // Memanggil fetchCart lagi untuk memperbarui state
    } catch (e) {
      print('CartCubit: Error adding to cart: $e'); // Debugging
      emit(CartError('Gagal menambahkan ke keranjang: $e'));
    }
  }

  Future<void> removeItem(String itemId) async {
    print('CartCubit: removeItem($itemId) called'); // Debugging
    emit(const CartLoading());
    try {
      await datasource.removeFromCart(itemId);
      print('CartCubit: Item removed, refetching cart...'); // Debugging
      await fetchCart();
    } catch (e) {
      print('CartCubit: Error removing item: $e'); // Debugging
      emit(CartError('Gagal menghapus item: $e'));
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    print('CartCubit: updateQuantity($itemId, $quantity) called'); // Debugging
    emit(const CartLoading());
    try {
      await datasource.updateQuantity(itemId, quantity);
      print('CartCubit: Quantity updated, refetching cart...'); // Debugging
      await fetchCart();
    } catch (e) {
      print('CartCubit: Error updating quantity: $e'); // Debugging
      emit(CartError('Gagal memperbarui jumlah: $e'));
    }
  }

  Future<void> clearCart() async {
    print('CartCubit: clearCart() called'); // Debugging
    emit(const CartLoading());
    try {
      await datasource.clearCart();
      print('CartCubit: Cart cleared, refetching cart...'); // Debugging
      emit(const CartLoaded(
          [])); // Bisa juga langsung emit list kosong setelah clear
      // Atau panggil fetchCart() jika clearCart di backend mengembalikan sesuatu
      // await fetchCart();
    } catch (e) {
      print('CartCubit: Error clearing cart: $e'); // Debugging
      emit(CartError('Gagal mengosongkan keranjang: $e'));
    }
  }

  // Reset state lokal tanpa memanggil API, misalnya saat logout
  void clearCartState() {
    print(
        'CartCubit: clearCartState() called. Emitting CartInitial().'); // Debugging
    emit(const CartInitial());
  }
}
