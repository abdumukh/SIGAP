import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

class NotifikasiService {
  final ApiClient _client;

  NotifikasiService({ApiClient? client}) : _client = client ?? ApiClient();

  Future<Response<dynamic>> getNotifikasiList({int perPage = 15}) async {
    return await _client.get('/notifikasi', queryParameters: {'per_page': perPage});
  }

  Future<Response<dynamic>> getNotifikasiById(String idNotifikasi) async {
    return await _client.get('/notifikasi/$idNotifikasi');
  }

  Future<Response<dynamic>> markAsRead(String idNotifikasi) async {
    return await _client.patch('/notifikasi/$idNotifikasi/read');
  }

  Future<Response<dynamic>> markAllAsRead() async {
    return await _client.patch('/notifikasi/read-all');
  }

  Future<Response<dynamic>> getUnreadCount() async {
    return await _client.get('/notifikasi/unread-count');
  }
}