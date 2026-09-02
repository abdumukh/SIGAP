import 'package:dio/dio.dart';
import '../models/dokumentasi_model.dart';
import '../services/dokumentasi_service.dart';

/// Repository for handling Dokumentasi data operations.
class DokumentasiRepository {
  final DokumentasiService service;

  DokumentasiRepository({required this.service});

  /// Fetches list of accessible Dokumentasi records.
  Future<List<DokumentasiModel>> getDokumentasiList() async {
    final response = await service.getDokumentasiList();
    final data = response.data;

    if (data is Map<String, dynamic> && data['data'] is List) {
      final list = data['data'] as List;
      return list
          .map((item) =>
              DokumentasiModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  /// Fetches single Dokumentasi record by ID.
  Future<DokumentasiModel> getDokumentasiById(String id) async {
    final response = await service.getDokumentasiById(id);
    final data = response.data;

    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      return DokumentasiModel.fromJson(data['data'] as Map<String, dynamic>);
    }

    throw Exception('Data dokumentasi tidak valid');
  }

  /// Creates and uploads a new Dokumentasi record.
  /// Supports Multipart file upload via FormData or string path.
  Future<DokumentasiModel> createDokumentasi({
    required String idPenanganan,
    required String jenisDokumentasi,
    required dynamic fileDokumentasi,
    String? note,
  }) async {
    dynamic payload;

    if (fileDokumentasi is MultipartFile) {
      final map = <String, dynamic>{
        'id_penanganan': idPenanganan,
        'jenis_dokumentasi': jenisDokumentasi,
        'file_dokumentasi': fileDokumentasi,
        if (note != null && note.isNotEmpty) 'note': note,
      };
      payload = FormData.fromMap(map);
    } else if (fileDokumentasi is FormData) {
      payload = fileDokumentasi;
    } else if (fileDokumentasi is Map<String, dynamic>) {
      payload = fileDokumentasi;
    } else {
      // String path or simple value
      final map = <String, dynamic>{
        'id_penanganan': idPenanganan,
        'jenis_dokumentasi': jenisDokumentasi,
        'file_dokumentasi': fileDokumentasi,
        if (note != null && note.isNotEmpty) 'note': note,
      };
      payload = map;
    }

    final response = await service.createDokumentasi(payload);
    final data = response.data;

    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      return DokumentasiModel.fromJson(data['data'] as Map<String, dynamic>);
    }

    throw Exception('Gagal membuat data dokumentasi');
  }

  /// Deletes a Dokumentasi record by ID.
  Future<bool> deleteDokumentasi(String id) async {
    final response = await service.deleteDokumentasi(id);
    final data = response.data;

    if (data is Map<String, dynamic> && data['status'] == 'success') {
      return true;
    }

    return false;
  }
}
