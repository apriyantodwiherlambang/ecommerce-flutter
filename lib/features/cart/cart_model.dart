// lib/features/cart/cart_model.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:equatable/equatable.dart'; // Import equatable

class CartItemModel extends Equatable {
  // Extend Equatable
  final String id;
  final int quantity;
  final String productId;
  final String productName;
  final String imageUrl;
  final int price;

  const CartItemModel({
    // Tambahkan const constructor
    required this.id,
    required this.quantity,
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.price,
  });

  // Constructor untuk quick add tanpa id dan productId, quantity default 1
  // Hati-hati dengan ini, sebaiknya jangan gunakan untuk objek yang akan disimpan di keranjang permanen.
  // Jika ini hanya untuk tampilan sementara, tidak masalah.
  // Jika ini untuk menambah ke keranjang, sebaiknya gunakan constructor utama.
  CartItemModel.simple({
    required this.productName,
    required this.price,
    required this.imageUrl,
  })  : id = DateTime.now().millisecondsSinceEpoch.toString(),
        productId = '',
        quantity = 1;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'];
    String rawImageUrl = product['image'] ?? '';
    // print('Raw imageUrl dari API (field imageUrl): $rawImageUrl'); // Hilangkan print ini di production

    if (rawImageUrl.isEmpty) {
      // print('Warning: imageUrl kosong untuk produk id=${product['id']}'); // Hilangkan print ini
      return CartItemModel(
        id: json['id'].toString(), // Pastikan id selalu string
        quantity: json['quantity'],
        productId: product['id'].toString(),
        productName: product['name'],
        imageUrl: '', // Jika kosong, set string kosong
        price: product['price'],
      );
    }

    // Ambil BASE_URL dari .env, pastikan ada protokol (http(s))
    // Pastikan dotenv.env['BASE_URL'] sudah di load di main.dart
    String baseUrl =
        dotenv.env['BASE_URL'] ?? 'http://localhost'; // Default fallback

    Uri? imageUri;
    try {
      imageUri = Uri.parse(rawImageUrl);
    } catch (e) {
      // print('Error parsing URL: $e'); // Hilangkan print ini
      imageUri = null;
    }

    String fixedImageUrl = rawImageUrl;

    if (imageUri != null) {
      final host = imageUri.host.toLowerCase();

      // Jika host adalah localhost atau IP lokal, ganti dengan BASE_URL dari .env
      if (host == 'localhost' ||
          host.startsWith('192.168.') ||
          host == '127.0.0.1') {
        Uri baseUri = Uri.parse(baseUrl);

        fixedImageUrl = Uri(
          scheme: baseUri.scheme,
          host: baseUri.host,
          port: baseUri.hasPort ? baseUri.port : null,
          path: imageUri.path,
          query: imageUri.query,
        ).toString();
      } else {
        // Host valid, gunakan rawImageUrl apa adanya
        fixedImageUrl = rawImageUrl;
      }
    }

    // print('Fixed imageUrl --: $fixedImageUrl'); // Hilangkan print ini

    return CartItemModel(
      id: json['id'].toString(), // Pastikan id selalu string
      quantity: json['quantity'],
      productId: product['id'].toString(), // Pastikan productId selalu string
      productName: product['name'],
      imageUrl: fixedImageUrl, // Gunakan fixedImageUrl yang sudah diproses
      price: product['price'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        quantity,
        productId,
        productName,
        imageUrl,
        price,
      ]; // Definisi prop Equatable
}
