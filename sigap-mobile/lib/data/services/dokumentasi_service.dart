import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

/// HTTP service for Dokumentasi endpoints.
class DokumentasiService {
  final ApiClient client;

  DokumentasiService({required this.client});

  /// GET /api/dokumentasi
  Future<Response> getDokumentasiList() => client.get('/dokumentasi');

  /// GET /api/dokumentasi/{id}
  Future<Response> getDokumentasiById(String id) =>
      client.get('/dokumentasi/$id');

  /// POST /api/dokumentasi (supports JSON map or Dio FormData)
  Future<Response> createDokumentasi(dynamic data) =>
      client.post('/dokumentasi', data: data);

  /// DELETE /api/dokumentasi/{id}
  Future<Response> deleteDokumentasi(String id) =>
      client.delete('/dokumentasi/$id');
}
