import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

/// Low-level HTTP service for Monitoring endpoint.
class MonitoringService {
  final ApiClient _client;

  MonitoringService({ApiClient? client}) : _client = client ?? ApiClient();

  /// GET /api/monitoring
  Future<Response<dynamic>> getMonitoring({Map<String, dynamic>? queryParameters}) async {
    return await _client.get(
      '/monitoring',
      queryParameters: queryParameters,
    );
  }
}