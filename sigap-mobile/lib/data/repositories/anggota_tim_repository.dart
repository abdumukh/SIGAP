import '../models/anggota_tim_model.dart';
import '../services/anggota_tim_service.dart';

/// Repository for handling AnggotaTim (Team Member) data operations.
class AnggotaTimRepository {
  final AnggotaTimService service;

  AnggotaTimRepository({required this.service});

  /// Fetches all members of a specific team.
  Future<List<AnggotaTimModel>> getAnggota(String idTim) async {
    final response = await service.getAnggota(idTim);
    final data = response.data;

    if (data is Map<String, dynamic> && data['data'] is List) {
      final list = data['data'] as List;
      return list
          .map((item) =>
              AnggotaTimModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  /// Adds a member (Petugas) to a specific team.
  Future<AnggotaTimModel> addAnggota(
    String idTim, {
    required String idPetugas,
    String? tanggalMasuk,
    String? statusAnggota,
  }) async {
    final payload = <String, dynamic>{
      'id_petugas': idPetugas,
      if (tanggalMasuk != null && tanggalMasuk.isNotEmpty)
        'tanggal_masuk': tanggalMasuk,
      'status_anggota': ?statusAnggota,
    };

    final response = await service.addAnggota(idTim, payload);
    final data = response.data;

    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      return AnggotaTimModel.fromJson(data['data'] as Map<String, dynamic>);
    }

    throw Exception('Gagal menambahkan anggota tim');
  }

  /// Updates status of a team member.
  Future<AnggotaTimModel> updateAnggota(
    String idTim,
    String idAnggota, {
    required String statusAnggota,
  }) async {
    final payload = <String, dynamic>{
      'status_anggota': statusAnggota,
    };

    final response = await service.updateAnggota(idTim, idAnggota, payload);
    final data = response.data;

    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      return AnggotaTimModel.fromJson(data['data'] as Map<String, dynamic>);
    }

    throw Exception('Gagal memperbarui status anggota tim');
  }

  /// Removes / deactivates a member from a team.
  Future<AnggotaTimModel> removeAnggota(
      String idTim, String idAnggota) async {
    final response = await service.removeAnggota(idTim, idAnggota);
    final data = response.data;

    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      return AnggotaTimModel.fromJson(data['data'] as Map<String, dynamic>);
    }

    throw Exception('Gagal menonaktifkan anggota tim');
  }
}
