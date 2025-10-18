import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../models/api_response_model.dart';
import '../../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProductsFromApi();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final http.Client httpClient;

  ProductRemoteDataSourceImpl({required this.httpClient});

  @override
  Future<List<ProductModel>> getProductsFromApi() async {
    try {
      final response = await httpClient
          .get(
            Uri.parse(ApiConstants.productsUrl),
            headers: ApiConstants.headers,
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        final apiResponse = ProductsApiResponse.fromJson(jsonResponse);

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw Exception(apiResponse.message);
        }
      } else if (response.statusCode == 404) {
        throw Exception('Products endpoint not found');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error: ${response.statusCode}');
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }
}
