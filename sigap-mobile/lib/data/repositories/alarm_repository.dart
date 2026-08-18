import '../models/alarm_model.dart';
import '../services/alarm_service.dart';

/// Repository abstracting data parsing and business operations for Alarms.
class AlarmRepository {
  final AlarmService _service;

  AlarmRepository({AlarmService? service}) : _service = service ?? AlarmService();

  /// Fetches alarm list (filtered automatically by backend for current role).
  Future<List<AlarmModel>> getAlarms() async {
    final response = await _service.getAlarms();
    final rawData = response.data;

    if (rawData is Map<String, dynamic> && rawData['data'] is List) {
      final list = rawData['data'] as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => AlarmModel.fromJson(item))
          .toList();
    }

    return [];
  }

  /// Fetches single alarm detail by ID.
  Future<AlarmModel> getAlarmById(String id) async {
    final response = await _service.getAlarmById(id);
    final rawData = response.data;

    if (rawData is Map<String, dynamic> && rawData['data'] is Map<String, dynamic>) {
      return AlarmModel.fromJson(rawData['data'] as Map<String, dynamic>);
    }

    throw Exception('Format response detail alarm tidak valid');
  }

  /// Creates a new alarm report (Masyarakat only).
  Future<AlarmModel> createAlarm({
    required String jenisDarurat,
    required double latitude,
    required double longitude,
    String? cuaca,
    String? laluLintas,
    DateTime? waktuAlarm,
  }) async {
    final payload = <String, dynamic>{
      'jenis_darurat': jenisDarurat,
      'latitude': latitude,
      'longitude': longitude,
      if (cuaca != null && cuaca.isNotEmpty) 'cuaca': cuaca,
      if (laluLintas != null && laluLintas.isNotEmpty) 'lalu_lintas': laluLintas,
      if (waktuAlarm != null) 'waktu_alarm': waktuAlarm.toIso8601String(),
    };

    final response = await _service.createAlarm(payload);
    final rawData = response.data;

    if (rawData is Map<String, dynamic> && rawData['data'] is Map<String, dynamic>) {
      return AlarmModel.fromJson(rawData['data'] as Map<String, dynamic>);
    }

    throw Exception('Format response pembuatan alarm tidak valid');
  }

  /// Verifies an alarm (Admin/Staff only).
  Future<AlarmModel> verifyAlarm(String id) async {
    final response = await _service.verifyAlarm(id);
    final rawData = response.data;

    if (rawData is Map<String, dynamic> && rawData['data'] is Map<String, dynamic>) {
      return AlarmModel.fromJson(rawData['data'] as Map<String, dynamic>);
    }

    throw Exception('Format response verifikasi alarm tidak valid');
  }

  /// Rejects an alarm (Admin/Staff only).
  Future<AlarmModel> rejectAlarm(String id) async {
    final response = await _service.rejectAlarm(id);
    final rawData = response.data;

    if (rawData is Map<String, dynamic> && rawData['data'] is Map<String, dynamic>) {
      return AlarmModel.fromJson(rawData['data'] as Map<String, dynamic>);
    }

    throw Exception('Format response penolakan alarm tidak valid');
  }

  /// Marks an alarm as completed (Admin/Staff only).
  Future<AlarmModel> completeAlarm(String id) async {
    final response = await _service.completeAlarm(id);
    final rawData = response.data;

    if (rawData is Map<String, dynamic> && rawData['data'] is Map<String, dynamic>) {
      return AlarmModel.fromJson(rawData['data'] as Map<String, dynamic>);
    }

    throw Exception('Format response penyelesaian alarm tidak valid');
  }

  /// Updates alarm status with transition matrix validation.
  Future<AlarmModel> updateStatus(String id, String targetStatus) async {
    final response = await _service.updateStatus(id, targetStatus);
    final rawData = response.data;

    if (rawData is Map<String, dynamic> && rawData['data'] is Map<String, dynamic>) {
      return AlarmModel.fromJson(rawData['data'] as Map<String, dynamic>);
    }

    throw Exception('Format response update status alarm tidak valid');
  }
}
