import '../models/penugasan_model.dart';
import '../services/penugasan_service.dart';

/// Repository for handling Penugasan data operations.
class PenugasanRepository {
  final PenugasanService service;

  PenugasanRepository({required this.service});

  /// Fetches the list of all assignments (Admin view).
  Future<List<PenugasanModel>> getPenugasanList() async {
    final response = await service.getPenugasanList();
    final data = response.data;

    if (data is Map<String, dynamic> && data['data'] is List) {
      final list = data['data'] as List;
      return list
          .map((item) =>
              PenugasanModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  /// Fetches a single assignment by ID.
  Future<PenugasanModel> getPenugasanById(String id) async {
    final response = await service.getPenugasanById(id);
    final data = response.data;

    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      return PenugasanModel.fromJson(data['data'] as Map<String, dynamic>);
    }

    throw Exception('Data penugasan tidak valid');
  }

  /// Creates a new assignment.
  Future<PenugasanModel> createPenugasan({
    required String idAlarm,
    required String idTim,
    required String idKetuaTim,
    String? idPetugasArmada,
    String? idArmada,
    String? waktuPenugasan,
    String? note,
  }) async {
    final payload = <String, dynamic>{
      'id_alarm': idAlarm,
      'id_tim': idTim,
      'id_ketua_tim': idKetuaTim,
      if (idPetugasArmada != null && idPetugasArmada.isNotEmpty)
        'id_petugas_armada': idPetugasArmada,
      if (idArmada != null && idArmada.isNotEmpty) 'id_armada': idArmada,
      if (waktuPenugasan != null && waktuPenugasan.isNotEmpty)
        'waktu_penugasan': waktuPenugasan,
      if (note != null && note.isNotEmpty) 'note': note,
    };

    final response = await service.createPenugasan(payload);
    final data = response.data;

    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      return PenugasanModel.fromJson(data['data'] as Map<String, dynamic>);
    }

    throw Exception('Gagal membuat penugasan');
  }
}
