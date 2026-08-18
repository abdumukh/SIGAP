import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

/// HTTP service for Penugasan endpoints — only responsible for raw HTTP calls.
class PenugasanService {
  final ApiClient client;

  PenugasanService({required this.client});

  /// GET /api/penugasan
  Future<Response> getPenugasanList() => client.get('/penugasan');

  /// GET /api/penugasan/{id}
  Future<Response> getPenugasanById(String id) => client.get('/penugasan/$id');

  /// POST /api/penugasan
  Future<Response> createPenugasan(Map<String, dynamic> data) =>
      client.post('/penugasan', data: data);
}
