import '../models/tim_model.dart';
import '../services/tim_service.dart';

/// Repository for handling Tim (Team) data transformations and API clean access.
class TimRepository {
  final TimService service;

  TimRepository({required this.service});

  /// Fetches the list of all teams with their members.
  Future<List<TimModel>> getTimList() async {
    final response = await service.getTimList();
    final data = response.data;

    if (data is Map<String, dynamic> && data['data'] is List) {
      final list = data['data'] as List;
      return list
          .map((item) => TimModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  /// Fetches a single team by ID.
  Future<TimModel> getTimById(String id) async {
    final response = await service.getTimById(id);
    final data = response.data;

    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      return TimModel.fromJson(data['data'] as Map<String, dynamic>);
    }

    throw Exception('Data tim tidak valid');
  }

  /// Creates a new team.
  Future<TimModel> createTim({
    required String namaTim,
    String? note,
    String? statusTim,
  }) async {
    final payload = <String, dynamic>{
      'nama_tim': namaTim,
      if (note != null && note.isNotEmpty) 'note': note,
      'status_tim': ?statusTim,
    };

    final response = await service.createTim(payload);
    final data = response.data;

    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      return TimModel.fromJson(data['data'] as Map<String, dynamic>);
    }

    throw Exception('Gagal membuat tim');
  }

  /// Updates an existing team.
  Future<TimModel> updateTim(
    String id, {
    String? namaTim,
    String? note,
    String? statusTim,
  }) async {
    final payload = <String, dynamic>{
      'nama_tim': ?namaTim,
      'note': ?note,
      'status_tim': ?statusTim,
    };

    final response = await service.updateTim(id, payload);
    final data = response.data;

    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      return TimModel.fromJson(data['data'] as Map<String, dynamic>);
    }

    throw Exception('Gagal memperbarui tim');
  }

  /// Deactivates / soft-deletes a team.
  Future<TimModel> deleteTim(String id) async {
    final response = await service.deleteTim(id);
    final data = response.data;

    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      return TimModel.fromJson(data['data'] as Map<String, dynamic>);
    }

    throw Exception('Gagal menonaktifkan tim');
  }
}
