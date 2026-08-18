import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

/// HTTP service for Tim endpoints — only responsible for raw HTTP calls.
class TimService {
  final ApiClient client;

  TimService({required this.client});

  /// GET /api/tim
  Future<Response> getTimList() => client.get('/tim');

  /// GET /api/tim/{id}
  Future<Response> getTimById(String id) => client.get('/tim/$id');

  /// POST /api/tim
  Future<Response> createTim(Map<String, dynamic> data) =>
      client.post('/tim', data: data);

  /// PUT /api/tim/{id}
  Future<Response> updateTim(String id, Map<String, dynamic> data) =>
      client.put('/tim/$id', data: data);

  /// DELETE /api/tim/{id}
  Future<Response> deleteTim(String id) => client.delete('/tim/$id');
}
