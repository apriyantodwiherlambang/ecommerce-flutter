import 'package:flutter_dotenv/flutter_dotenv.dart';

class CartItemModel {
  final String id;
  final int quantity;
  final String productId;
  final String productName;
  final String imageUrl;
  final int price;

  CartItemModel({
    required this.id,
    required this.quantity,
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.price,
  });

  // Constructor untuk quick add tanpa id dan productId, quantity default 1
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
    print('Raw imageUrl dari API (field imageUrl): $rawImageUrl');

    if (rawImageUrl.isEmpty) {
      print('Warning: imageUrl kosong untuk produk id=${product['id']}');
      return CartItemModel(
        id: json['id'],
        quantity: json['quantity'],
        productId: product['id'].toString(),
        productName: product['name'],
        imageUrl: 'image',
        price: product['price'],
      );
    }

    // Ambil BASE_URL dari .env, pastikan ada protokol (http(s))
    String baseUrl = 'http://192.168.1.6';

    Uri? imageUri;
    try {
      imageUri = Uri.parse(rawImageUrl);
    } catch (e) {
      print('Error parsing URL: $e');
      imageUri = null;
    }

    String fixedImageUrl = rawImageUrl;

    if (imageUri != null) {
      final host = imageUri.host.toLowerCase();

      // Jika host adalah localhost atau IP lokal, ganti dengan BASE_URL
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

    print('Fixed imageUrl --: $fixedImageUrl');

    return CartItemModel(
      id: json['id'],
      quantity: json['quantity'],
      productId: product['id'].toString(),
      productName: product['name'],
      imageUrl: product['image'],
      price: product['price'],
    );
  }
}
