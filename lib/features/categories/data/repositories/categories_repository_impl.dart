import '../../domain/repositories/categories_repository.dart';
import '../datasources/categories_remote_datasource.dart';
import '../models/category_model.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  final CategoriesRemoteDatasource remote;

  CategoriesRepositoryImpl(this.remote);

  @override
  Future<List<CategoryModel>> getCategories() {
    return remote.fetchCategories();
  }
}
