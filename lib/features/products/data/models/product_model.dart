// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:frontend_ecommerce/features/categories/data/models/category_model.dart';
// import '../../domain/entities/product_entities.dart';

// class ProductModel extends ProductEntity {
//   const ProductModel({
//     required super.id,
//     required super.name,
//     required super.description,
//     required super.price,
//     required super.stock,
//     required super.imageUrl,
//     required super.categoryId,
//     super.category,
//   });

//   factory ProductModel.fromJson(Map<String, dynamic> json) {
//     String rawImageUrl = json['image'] ?? '';
//     print('Raw imageUrl dari API (field image): $rawImageUrl');
//     if (rawImageUrl.isEmpty) {
//       print('Warning: imageUrl kosong untuk produk id=${json['id']}');
//     }

//     String fixedImageUrl = rawImageUrl.replaceAll(
//       'localhost',
//       dotenv.env['BASE_URL'] ?? '192.168.1.6',
//     );

//     print('Raw imageUrl: $rawImageUrl');

//     return ProductModel(
//       id: json['id'],
//       name: json['name'],
//       description: json['description'],
//       price: json['price'],
//       stock: json['stock'],
//       imageUrl: fixedImageUrl,
//       categoryId: json['categoryId'],
//       category: json['category'] != null
//           ? CategoryModel.fromJson(json['category'])
//           : null,
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'name': name,
//         'description': description,
//         'price': price,
//         'stock': stock,
//         'imageUrl': imageUrl,
//         'categoryId': categoryId,
//         'category': (category as CategoryModel?)?.toJson(),
//       };
// }

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_ecommerce/features/categories/data/models/category_model.dart';
import '../../domain/entities/product_entities.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.stock,
    required super.imageUrl,
    required super.categoryId,
    super.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    String rawImageUrl = json['image'] ?? '';
    print('Raw imageUrl dari API (field image): $rawImageUrl');

    if (rawImageUrl.isEmpty) {
      print('Warning: imageUrl kosong untuk produk id=${json['id']}');
      return ProductModel(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        price: json['price'],
        stock: json['stock'],
        imageUrl: '',
        categoryId: json['categoryId'],
        category: json['category'] != null
            ? CategoryModel.fromJson(json['category'])
            : null,
      );
    }

    // Ambil BASE_URL dari .env, pastikan ada protokol (http(s))
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://192.168.1.6';

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
        // parse BASE_URL agar bisa digabung
        Uri baseUri = Uri.parse(baseUrl);

        // Gabungkan BASE_URL dengan path dan query dari rawImageUrl
        fixedImageUrl = Uri(
          scheme: baseUri.scheme,
          host: baseUri.host,
          port: baseUri.hasPort ? baseUri.port : null,
          path: imageUri.path,
          query: imageUri.query,
        ).toString();
      } else {
        // Bukan localhost / IP lokal, gunakan apa adanya
        fixedImageUrl = rawImageUrl;
      }
    }

    print('Fixed imageUrl: $fixedImageUrl');

    return ProductModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      stock: json['stock'],
      imageUrl: fixedImageUrl,
      categoryId: json['categoryId'],
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'imageUrl': imageUrl,
        'categoryId': categoryId,
        'category': (category as CategoryModel?)?.toJson(),
      };
}
