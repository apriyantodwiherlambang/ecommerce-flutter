import '../../data/models/category_model.dart';
import '../repositories/categories_repository.dart';

class FetchCategories {
  final CategoriesRepository repository;

  FetchCategories(this.repository);

  Future<List<CategoryModel>> call() {
    return repository.getCategories();
  }
}
