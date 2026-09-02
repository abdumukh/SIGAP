import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

/// HTTP service for Korban endpoints.
class KorbanService {
  final ApiClient client;

  KorbanService({required this.client});

  /// GET /api/korban
  Future<Response> getKorbanList() => client.get('/korban');

  /// GET /api/korban/{id}
  Future<Response> getKorbanById(String id) =>
      client.get('/korban/$id');

  /// POST /api/korban
  Future<Response> createKorban(Map<String, dynamic> data) =>
      client.post('/korban', data: data);

  /// DELETE /api/korban/{id}
  Future<Response> deleteKorban(String id) =>
      client.delete('/korban/$id');
}