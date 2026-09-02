import '../models/monitoring_model.dart';
import '../services/monitoring_service.dart';

/// Repository abstracting data parsing for Monitoring endpoint.
class MonitoringRepository {
  final MonitoringService _service;

  MonitoringRepository({MonitoringService? service})
      : _service = service ?? MonitoringService();

  /// Fetches monitoring data with optional filters.
  Future<MonitoringModel> getMonitoring({
    String? startDate,
    String? endDate,
    String? status,
    String? jenisDarurat,
    String? idTim,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (startDate != null && startDate.isNotEmpty) queryParams['start_date'] = startDate;
    if (endDate != null && endDate.isNotEmpty) queryParams['end_date'] = endDate;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (jenisDarurat != null && jenisDarurat.isNotEmpty) {
      queryParams['jenis_darurat'] = jenisDarurat;
    }
    if (idTim != null && idTim.isNotEmpty) queryParams['id_tim'] = idTim;

    final response = await _service.getMonitoring(queryParameters: queryParams);
    final rawData = response.data;

    if (rawData is Map<String, dynamic>) {
      return MonitoringModel.fromJson(rawData);
    }

    throw Exception('Format response monitoring tidak valid');
  }
}