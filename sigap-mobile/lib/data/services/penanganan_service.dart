import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

/// HTTP service for Penanganan endpoints.
class PenangananService {
  final ApiClient client;

  PenangananService({required this.client});

  /// GET /api/penanganan
  Future<Response> getPenangananList() => client.get('/penanganan');

  /// GET /api/penanganan/{id}
  Future<Response> getPenangananById(String id) =>
      client.get('/penanganan/$id');

  /// POST /api/penanganan
  Future<Response> createPenanganan(Map<String, dynamic> data) =>
      client.post('/penanganan', data: data);

  /// PATCH /api/penanganan/{id}
  Future<Response> updatePenanganan(
          String id, Map<String, dynamic> data) =>
      client.patch('/penanganan/$id', data: data);
}
