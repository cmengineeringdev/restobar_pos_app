import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../models/order_request_model.dart';

abstract class OrderRemoteDataSource {
  Future<void> sendOrderToApi(OrderRequestModel orderRequest);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final http.Client httpClient;

  OrderRemoteDataSourceImpl({required this.httpClient});

  @override
  Future<void> sendOrderToApi(OrderRequestModel orderRequest) async {
    try {
      final response = await httpClient
          .post(
            Uri.parse(ApiConstants.ordersUrl),
            headers: {
              ...ApiConstants.headers,
              'Content-Type': 'application/json',
            },
            body: json.encode(orderRequest.toJson()),
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Orden enviada exitosamente
        print('DEBUG REMOTE ORDER: Orden enviada exitosamente al servidor remoto');
        return;
      } else if (response.statusCode == 400) {
        final jsonResponse = json.decode(response.body);
        throw Exception(
            'Datos de orden inválidos: ${jsonResponse['message'] ?? 'Unknown error'}');
      } else if (response.statusCode >= 500) {
        throw Exception('Error del servidor: ${response.statusCode}');
      } else {
        throw Exception('Error al enviar orden: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error de red al enviar orden: $e');
    }
  }
}
