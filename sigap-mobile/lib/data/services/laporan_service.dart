import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

/// Low-level HTTP service for Laporan endpoint.
class LaporanService {
  final ApiClient _client;

  LaporanService({ApiClient? client}) : _client = client ?? ApiClient();

  /// GET /api/laporan?type={type}
  Future<Response<dynamic>> getLaporan({required Map<String, dynamic> queryParameters}) async {
    return await _client.get(
      '/laporan',
      queryParameters: queryParameters,
    );
  }
}