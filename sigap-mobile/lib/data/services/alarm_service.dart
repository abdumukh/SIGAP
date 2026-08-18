import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

/// Low-level HTTP communication service for Alarm endpoints.
class AlarmService {
  final ApiClient _client;

  AlarmService({ApiClient? client}) : _client = client ?? ApiClient();

  /// GET /api/alarms
  Future<Response<dynamic>> getAlarms() async {
    return await _client.get('/alarms');
  }

  /// GET /api/alarms/{id}
  Future<Response<dynamic>> getAlarmById(String id) async {
    return await _client.get('/alarms/$id');
  }

  /// POST /api/alarms (Masyarakat only)
  Future<Response<dynamic>> createAlarm(Map<String, dynamic> data) async {
    return await _client.post(
      '/alarms',
      data: data,
    );
  }

  /// POST/PATCH /api/alarms/{id}/verify (Admin & Staff)
  Future<Response<dynamic>> verifyAlarm(String id) async {
    return await _client.post('/alarms/$id/verify');
  }

  /// POST/PATCH /api/alarms/{id}/reject (Admin & Staff)
  Future<Response<dynamic>> rejectAlarm(String id) async {
    return await _client.post('/alarms/$id/reject');
  }

  /// POST/PATCH /api/alarms/{id}/complete (Admin & Staff)
  Future<Response<dynamic>> completeAlarm(String id) async {
    return await _client.post('/alarms/$id/complete');
  }

  /// PATCH /api/alarms/{id}/status (Admin & Staff)
  Future<Response<dynamic>> updateStatus(String id, String statusAlarm) async {
    return await _client.patch(
      '/alarms/$id/status',
      data: {
        'status_alarm': statusAlarm,
      },
    );
  }
}
