import '../models/logistik_model.dart';
import '../services/logistik_service.dart';

/// Repository for handling Logistik data operations.
class LogistikRepository {
  final LogistikService service;

  LogistikRepository({required this.service});

  /// Fetches list of accessible Logistik records.
  Future<List<LogistikModel>> getLogistikList() async {
    final response = await service.getLogistikList();
    final data = response.data;

    if (data is Map<String, dynamic> && data['data'] is List) {
      final list = data['data'] as List;
      return list
          .map((item) =>
              LogistikModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  /// Fetches single Logistik record by ID.
  Future<LogistikModel> getLogistikById(String id) async {
    final response = await service.getLogistikById(id);
    final data = response.data;

    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      return LogistikModel.fromJson(data['data'] as Map<String, dynamic>);
    }

    throw Exception('Data logistik tidak valid');
  }

  /// Creates a new Logistik record.
  Future<LogistikModel> createLogistik({
    required String idPenanganan,
    required String namaLogistik,
    required int jumlah,
    required String satuan,
    required String kondisi,
    String? note,
  }) async {
    final map = <String, dynamic>{
      'id_penanganan': idPenanganan,
      'nama_logistik': namaLogistik,
      'jumlah': jumlah,
      'satuan': satuan,
      'kondisi': kondisi,
      if (note != null && note.isNotEmpty) 'note': note,
    };

    final response = await service.createLogistik(map);
    final data = response.data;

    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      return LogistikModel.fromJson(data['data'] as Map<String, dynamic>);
    }

    throw Exception('Gagal membuat data logistik');
  }

  /// Deletes a Logistik record by ID.
  Future<bool> deleteLogistik(String id) async {
    final response = await service.deleteLogistik(id);
    final data = response.data;

    if (data is Map<String, dynamic> && data['status'] == 'success') {
      return true;
    }

    return false;
  }
}