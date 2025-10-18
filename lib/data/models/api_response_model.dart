import 'product_model.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
    );
  }
}

class ProductsApiResponse extends ApiResponse<List<ProductModel>> {
  ProductsApiResponse({
    required super.success,
    required super.message,
    super.data,
  });

  factory ProductsApiResponse.fromJson(Map<String, dynamic> json) {
    List<ProductModel>? products;

    if (json['data'] != null) {
      final dataList = json['data'] as List;
      products = dataList
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return ProductsApiResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: products,
    );
  }
}
