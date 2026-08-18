import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

/// HTTP service for AnggotaTim endpoints — only responsible for raw HTTP calls.
class AnggotaTimService {
  final ApiClient client;

  AnggotaTimService({required this.client});

  /// GET /api/tim/{id}/anggota
  Future<Response> getAnggota(String idTim) =>
      client.get('/tim/$idTim/anggota');

  /// POST /api/tim/{id}/anggota
  Future<Response> addAnggota(String idTim, Map<String, dynamic> data) =>
      client.post('/tim/$idTim/anggota', data: data);

  /// PATCH /api/tim/{id}/anggota/{idAnggota}
  Future<Response> updateAnggota(
          String idTim, String idAnggota, Map<String, dynamic> data) =>
      client.patch('/tim/$idTim/anggota/$idAnggota', data: data);

  /// DELETE /api/tim/{id}/anggota/{idAnggota}
  Future<Response> removeAnggota(String idTim, String idAnggota) =>
      client.delete('/tim/$idTim/anggota/$idAnggota');
}
