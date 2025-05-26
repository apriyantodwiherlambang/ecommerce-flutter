import 'package:frontend_ecommerce/features/categories/data/models/category_model.dart';

abstract class CategoriesRemoteDatasource {
  Future<List<CategoryModel>> fetchCategories();
}
