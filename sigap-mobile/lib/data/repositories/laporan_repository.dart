import '../models/laporan_model.dart';
import '../services/laporan_service.dart';

/// Repository abstracting data parsing for Laporan endpoint.
class LaporanRepository {
  final LaporanService _service;

  LaporanRepository({LaporanService? service})
      : _service = service ?? LaporanService();

  /// Fetches laporan (rekap) for a given type and filters.
  Future<LaporanModel> getLaporan({required LaporanFilter filter}) async {
    if (filter.type == null || filter.type!.isEmpty) {
      throw ArgumentError('Laporan type wajib diisi');
    }

    final response = await _service.getLaporan(
      queryParameters: filter.toQueryParameters(),
    );
    final rawData = response.data;

    if (rawData is Map<String, dynamic>) {
      return LaporanModel.fromJson(rawData);
    }

    throw Exception('Format response laporan tidak valid');
  }
}