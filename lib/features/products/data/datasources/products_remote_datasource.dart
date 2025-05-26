import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend_ecommerce/features/auth/data/api_service.dart';
import 'package:frontend_ecommerce/features/products/data/models/product_model.dart';

abstract class ProductsRemoteDataSource {
  Future<ProductModel> uploadProduct({
    required String name,
    required String description,
    required int price,
    required int stock,
    required String categoryId,
    required File imageFile,
  });

  Future<List<ProductModel>> getAllProducts(); // <-- Tambahkan ini
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  final Dio dio;
  final ApiService apiService;

  ProductsRemoteDataSourceImpl(this.dio, this.apiService) {
    dio.options.baseUrl = 'https://44ba-66-96-225-191.ngrok-free.app';
  }

  @override
  Future<ProductModel> uploadProduct({
    required String name,
    required String description,
    required int price,
    required int stock,
    required String categoryId,
    required File imageFile,
  }) async {
    final token = await apiService.getJwt(); // Ambil token terbaru
    if (token == null || token.isEmpty) {
      throw Exception('JWT kosong, silakan login ulang');
    }

    final formData = FormData.fromMap({
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category_id': categoryId,
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split(Platform.pathSeparator).last,
      ),
    });

    if (kDebugMode) {
      print('Mengirim request upload produk...');
      print(
          'FormData fields: name=$name, description=$description, price=$price, stock=$stock, category_id=$categoryId');
      print('File path: ${imageFile.path}');
      print('JWT yang digunakan: $token');
    }

    try {
      final response = await dio.post(
        '/products',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (kDebugMode) {
        print('Response status code: ${response.statusCode}');
        print('Response data: ${response.data}');
      }

      if (response.statusCode == 201) {
        return ProductModel.fromJson(response.data['data']);
      } else {
        throw Exception(
            'Gagal upload produk, status code: ${response.statusCode}');
      }
    } on DioError catch (dioError) {
      if (kDebugMode) {
        print('DioError saat upload produk:');
        if (dioError.response != null) {
          print('Status code: ${dioError.response?.statusCode}');
          print('Response data: ${dioError.response?.data}');
        } else {
          print('Error message: ${dioError.message}');
        }
      }
      final message = dioError.response?.data?['message'] ?? dioError.message;
      throw Exception('Gagal upload produk: $message');
    } catch (e) {
      if (kDebugMode) print('Error umum saat upload produk: $e');
      rethrow;
    }
  }

  @override
  Future<List<ProductModel>> getAllProducts() async {
    final token = await apiService.getJwt();
    if (token == null || token.isEmpty) {
      throw Exception('JWT kosong, silakan login ulang');
    }

    try {
      final response = await dio.get(
        '/products',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (kDebugMode) {
        print('Response status code (getAllProducts): ${response.statusCode}');
        print('Response data (getAllProducts): ${response.data}');
      }

      if (response.statusCode == 200) {
        // Anggap response.data['data'] adalah list JSON produk
        final List data = response.data as List;
        print('Raw Response: ${response.data}');
        return data.map((e) => ProductModel.fromJson(e)).toList();
      } else {
        throw Exception(
            'Gagal mengambil produk, status code: ${response.statusCode}');
      }
    } on DioError catch (dioError) {
      if (kDebugMode) {
        print('DioError saat getAllProducts:');
        if (dioError.response != null) {
          print('Status code: ${dioError.response?.statusCode}');
          print('Response data: ${dioError.response?.data}');
        } else {
          print('Error message: ${dioError.message}');
        }
      }
      final message = dioError.response?.data?['message'] ?? dioError.message;
      throw Exception('Gagal mengambil produk: $message');
    } catch (e) {
      if (kDebugMode) print('Error umum saat getAllProducts: $e');
      rethrow;
    }
  }
}
