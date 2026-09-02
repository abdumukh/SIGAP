import '../models/korban_model.dart';
import '../services/korban_service.dart';

/// Repository for handling Korban data operations.
class KorbanRepository {
  final KorbanService service;

  KorbanRepository({required this.service});

  /// Fetches list of accessible Korban records.
  Future<List<KorbanModel>> getKorbanList() async {
    final response = await service.getKorbanList();
    final data = response.data;

    if (data is Map<String, dynamic> && data['data'] is List) {
      final list = data['data'] as List;
      return list
          .map((item) =>
              KorbanModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  /// Fetches single Korban record by ID.
  Future<KorbanModel> getKorbanById(String id) async {
    final response = await service.getKorbanById(id);
    final data = response.data;

    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      return KorbanModel.fromJson(data['data'] as Map<String, dynamic>);
    }

    throw Exception('Data korban tidak valid');
  }

  /// Creates a new Korban record.
  Future<KorbanModel> createKorban({
    required String idPenanganan,
    required String namaKorban,
    required String jenisKelamin,
    required int usia,
    required String kondisi,
    required String statusPenanganan,
    String? note,
  }) async {
    final map = <String, dynamic>{
      'id_penanganan': idPenanganan,
      'nama_korban': namaKorban,
      'jenis_kelamin': jenisKelamin,
      'usia': usia,
      'kondisi': kondisi,
      'status_penanganan': statusPenanganan,
      if (note != null && note.isNotEmpty) 'note': note,
    };

    final response = await service.createKorban(map);
    final data = response.data;

    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      return KorbanModel.fromJson(data['data'] as Map<String, dynamic>);
    }

    throw Exception('Gagal membuat data korban');
  }

  /// Deletes a Korban record by ID.
  Future<bool> deleteKorban(String id) async {
    final response = await service.deleteKorban(id);
    final data = response.data;

    if (data is Map<String, dynamic> && data['status'] == 'success') {
      return true;
    }

    return false;
  }
}