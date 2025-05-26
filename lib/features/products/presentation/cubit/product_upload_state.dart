import 'package:frontend_ecommerce/features/products/domain/entities/product_entities.dart';

abstract class ProductUploadState {}

class ProductUploadInitial extends ProductUploadState {}

class ProductUploadLoading extends ProductUploadState {}

class ProductUploadSuccess extends ProductUploadState {
  final ProductEntity product;
  ProductUploadSuccess(this.product);
}

class ProductUploadFailure extends ProductUploadState {
  final String message;
  ProductUploadFailure(this.message);
}
