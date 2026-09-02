import '../models/penanganan_model.dart';
import '../services/penanganan_service.dart';

/// Repository for handling Penanganan data operations.
class PenangananRepository {
  final PenangananService service;

  PenangananRepository({required this.service});

  /// Fetches list of accessible Penanganan records.
  Future<List<PenangananModel>> getPenangananList() async {
    final response = await service.getPenangananList();
    final data = response.data;

    if (data is Map<String, dynamic> && data['data'] is List) {
      final list = data['data'] as List;
      return list
          .map((item) =>
              PenangananModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  /// Fetches single Penanganan record by ID.
  Future<PenangananModel> getPenangananById(String id) async {
    final response = await service.getPenangananById(id);
    final data = response.data;

    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      return PenangananModel.fromJson(data['data'] as Map<String, dynamic>);
    }

    throw Exception('Data penanganan tidak valid');
  }

  /// Creates a new Penanganan from an assigned Penugasan.
  Future<PenangananModel> createPenanganan({
    required String idPenugasan,
    String? note,
  }) async {
    final payload = <String, dynamic>{
      'id_penugasan': idPenugasan,
      if (note != null && note.isNotEmpty) 'note': note,
    };

    final response = await service.createPenanganan(payload);
    final data = response.data;

    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      return PenangananModel.fromJson(data['data'] as Map<String, dynamic>);
    }

    throw Exception('Gagal membuat data penanganan');
  }

  /// Updates status of Penanganan (menuju_lokasi -> di_lokasi -> selesai).
  Future<PenangananModel> updatePenangananStatus(
    String id, {
    required String statusPenanganan,
    String? note,
  }) async {
    final payload = <String, dynamic>{
      'status_penanganan': statusPenanganan,
      if (note != null && note.isNotEmpty) 'note': note,
    };

    final response = await service.updatePenanganan(id, payload);
    final data = response.data;

    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      return PenangananModel.fromJson(data['data'] as Map<String, dynamic>);
    }

    throw Exception('Gagal memperbarui status penanganan');
  }
}
