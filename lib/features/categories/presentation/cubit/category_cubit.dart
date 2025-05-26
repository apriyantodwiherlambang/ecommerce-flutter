import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../categories/data/models/category_model.dart';
import '../../domain/usecases/fetch_categories.dart';

abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<CategoryModel> categories;
  CategoryLoaded(this.categories);
}

class CategoryError extends CategoryState {
  final String message;
  CategoryError(this.message);
}

class CategoryCubit extends Cubit<CategoryState> {
  final FetchCategories fetchCategories;

  CategoryCubit(this.fetchCategories) : super(CategoryInitial());

  void loadCategories() async {
    emit(CategoryLoading());
    try {
      final categories = await fetchCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}
