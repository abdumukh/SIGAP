import '../models/notifikasi_model.dart';
import '../services/notifikasi_service.dart';

class NotifikasiRepository {
  final NotifikasiService _service;

  NotifikasiRepository({NotifikasiService? service}) : _service = service ?? NotifikasiService();

  Future<List<NotifikasiModel>> getNotifikasiList({int perPage = 15}) async {
    final response = await _service.getNotifikasiList(perPage: perPage);
    final rawData = response.data;

    if (rawData is Map<String, dynamic> && rawData['data'] is List) {
      final list = rawData['data'] as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => NotifikasiModel.fromJson(item))
          .toList();
    }

    return [];
  }

  Future<NotifikasiModel> getNotifikasiById(String idNotifikasi) async {
    final response = await _service.getNotifikasiById(idNotifikasi);
    final rawData = response.data;

    if (rawData is Map<String, dynamic> && rawData['data'] is Map<String, dynamic>) {
      return NotifikasiModel.fromJson(rawData['data'] as Map<String, dynamic>);
    }

    throw Exception('Format response detail notifikasi tidak valid');
  }

  Future<NotifikasiModel> markAsRead(String idNotifikasi) async {
    final response = await _service.markAsRead(idNotifikasi);
    final rawData = response.data;

    if (rawData is Map<String, dynamic> && rawData['data'] is Map<String, dynamic>) {
      return NotifikasiModel.fromJson(rawData['data'] as Map<String, dynamic>);
    }

    throw Exception('Format response mark as read tidak valid');
  }

  Future<int> markAllAsRead() async {
    final response = await _service.markAllAsRead();
    final rawData = response.data;

    if (rawData is Map<String, dynamic> && rawData['data'] is Map<String, dynamic>) {
      return (rawData['data']['updated_count'] as num?)?.toInt() ?? 0;
    }

    return 0;
  }

  Future<int> getUnreadCount() async {
    final response = await _service.getUnreadCount();
    final rawData = response.data;

    if (rawData is Map<String, dynamic> && rawData['data'] is Map<String, dynamic>) {
      return (rawData['data']['unread_count'] as num?)?.toInt() ?? 0;
    }

    return 0;
  }
}