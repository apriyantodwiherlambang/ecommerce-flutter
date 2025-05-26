import 'package:dio/dio.dart';
import '../models/category_model.dart';
import 'categories_remote_datasource.dart';

class CategoriesRemoteDatasourceImpl implements CategoriesRemoteDatasource {
  final Dio dio;

  CategoriesRemoteDatasourceImpl(this.dio);

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    final response = await dio.get('/categories');

    if (response.statusCode == 200) {
      final List list = response.data;
      return list.map((e) => CategoryModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat kategori');
    }
  }
}
