import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

/// HTTP service for Logistik endpoints.
class LogistikService {
  final ApiClient client;

  LogistikService({required this.client});

  /// GET /api/logistik
  Future<Response> getLogistikList() => client.get('/logistik');

  /// GET /api/logistik/{id}
  Future<Response> getLogistikById(String id) =>
      client.get('/logistik/$id');

  /// POST /api/logistik
  Future<Response> createLogistik(Map<String, dynamic> data) =>
      client.post('/logistik', data: data);

  /// DELETE /api/logistik/{id}
  Future<Response> deleteLogistik(String id) =>
      client.delete('/logistik/$id');
}