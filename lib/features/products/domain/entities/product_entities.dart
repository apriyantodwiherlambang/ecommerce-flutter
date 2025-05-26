import 'package:frontend_ecommerce/features/categories/domain/entities/category_entity.dart';

class ProductEntity {
  final String id;
  final String name;
  final String description;
  final int price;
  final int stock;
  final String imageUrl;
  final String categoryId;
  final CategoryEntity? category; // Tambahan property category

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.categoryId,
    this.category, // nullable agar fleksibel
  });
}
