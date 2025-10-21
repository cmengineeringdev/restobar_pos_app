import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../models/work_shift_model.dart';

abstract class WorkShiftRemoteDataSource {
  Future<WorkShiftModel?> getActiveWorkShift(int pointOfSaleId);
  Future<WorkShiftModel> openWorkShift(int pointOfSaleId);
  Future<WorkShiftModel> closeWorkShift(int workShiftId, int pointOfSaleId);
}

class WorkShiftRemoteDataSourceImpl implements WorkShiftRemoteDataSource {
  final http.Client httpClient;

  WorkShiftRemoteDataSourceImpl({required this.httpClient});

  @override
  Future<WorkShiftModel?> getActiveWorkShift(int pointOfSaleId) async {
    try {
      final url = Uri.parse(
          '${ApiConstants.baseUrl}/api/workshift/active?pointOfSaleId=$pointOfSaleId');

      final response =
          await httpClient.get(url).timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        final workShiftResponse = WorkShiftResponse.fromJson(jsonResponse);

        if (workShiftResponse.success) {
          return workShiftResponse.data;
        } else {
          throw Exception(workShiftResponse.message);
        }
      } else if (response.statusCode == 404) {
        throw Exception('WorkShift endpoint not found');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error: ${response.statusCode}');
      } else {
        throw Exception(
            'Failed to get active work shift: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<WorkShiftModel> openWorkShift(int pointOfSaleId) async {
    try {
      final url =
          Uri.parse('${ApiConstants.baseUrl}/api/workshift/open');

      final response = await httpClient
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'pointOfSaleId': pointOfSaleId}),
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        final workShiftResponse = WorkShiftResponse.fromJson(jsonResponse);

        if (workShiftResponse.success && workShiftResponse.data != null) {
          return workShiftResponse.data!;
        } else {
          throw Exception(workShiftResponse.message);
        }
      } else if (response.statusCode == 400) {
        // Manejar caso donde ya existe un turno abierto
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        throw Exception(jsonResponse['message'] ?? 'Bad request');
      } else if (response.statusCode == 404) {
        throw Exception('WorkShift endpoint not found');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error: ${response.statusCode}');
      } else {
        throw Exception('Failed to open work shift: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<WorkShiftModel> closeWorkShift(int workShiftId, int pointOfSaleId) async {
    try {
      final url =
          Uri.parse('${ApiConstants.baseUrl}/api/workshift/close/$workShiftId');
      print('DEBUG REMOTE: Haciendo POST a: $url');
      print('DEBUG REMOTE: Body: ${json.encode({'pointOfSaleId': pointOfSaleId})}');

      final response = await httpClient
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'pointOfSaleId': pointOfSaleId}),
          )
          .timeout(ApiConstants.connectionTimeout);

      print('DEBUG REMOTE: Status code: ${response.statusCode}');
      print('DEBUG REMOTE: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        final workShiftResponse = WorkShiftResponse.fromJson(jsonResponse);

        if (workShiftResponse.success && workShiftResponse.data != null) {
          print('DEBUG REMOTE: Turno cerrado exitosamente');
          return workShiftResponse.data!;
        } else {
          print('DEBUG REMOTE: Respuesta no exitosa: ${workShiftResponse.message}');
          throw Exception(workShiftResponse.message);
        }
      } else if (response.statusCode == 400) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        print('DEBUG REMOTE: Error 400: ${jsonResponse['message']}');
        throw Exception(jsonResponse['message'] ?? 'Bad request');
      } else if (response.statusCode == 404) {
        print('DEBUG REMOTE: Error 404: Endpoint no encontrado');
        throw Exception('WorkShift endpoint not found');
      } else if (response.statusCode >= 500) {
        print('DEBUG REMOTE: Error del servidor: ${response.statusCode}');
        throw Exception('Server error: ${response.statusCode}');
      } else {
        print('DEBUG REMOTE: Error desconocido: ${response.statusCode}');
        throw Exception('Failed to close work shift: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG REMOTE: Excepción capturada: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }
}

