import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../models/point_of_sale_model.dart';

abstract class PointOfSaleRemoteDataSource {
  Future<List<PointOfSaleModel>> getPointsOfSale();
}

class PointOfSaleRemoteDataSourceImpl implements PointOfSaleRemoteDataSource {
  final http.Client httpClient;

  PointOfSaleRemoteDataSourceImpl({required this.httpClient});

  @override
  Future<List<PointOfSaleModel>> getPointsOfSale() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/pointOfSale');

      final response =
          await httpClient.get(url).timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        final posResponse = PointOfSalesResponse.fromJson(jsonResponse);

        if (posResponse.success && posResponse.data != null) {
          return posResponse.data!;
        } else {
          throw Exception(posResponse.message);
        }
      } else if (response.statusCode == 404) {
        throw Exception('Points of sale endpoint not found');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error: ${response.statusCode}');
      } else {
        throw Exception(
            'Failed to load points of sale: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }
}
