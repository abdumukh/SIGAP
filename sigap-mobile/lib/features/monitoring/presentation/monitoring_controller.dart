import 'package:flutter/foundation.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../data/models/monitoring_model.dart';
import '../../../data/repositories/monitoring_repository.dart';

enum MonitoringStateStatus {
  initial,
  loading,
  loaded,
  refreshing,
  error,
}

/// Reactive controller for Monitoring data (statistik + active operations).
class MonitoringController extends ChangeNotifier {
  final MonitoringRepository _repository;

  MonitoringStateStatus _status = MonitoringStateStatus.initial;
  MonitoringModel? _data;
  String? _errorMessage;

  // Filters
  String? _startDate;
  String? _endDate;
  String? _statusFilter;
  String? _jenisDarurat;
  String? _idTim;

  MonitoringController({MonitoringRepository? repository})
      : _repository = repository ?? MonitoringRepository();

  // Getters
  MonitoringStateStatus get status => _status;
  MonitoringModel? get data => _data;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == MonitoringStateStatus.loading;
  bool get isRefreshing => _status == MonitoringStateStatus.refreshing;
  bool get isLoaded => _status == MonitoringStateStatus.loaded;
  bool get hasError => _status == MonitoringStateStatus.error;
  bool get isEmpty => _data == null || _data!.activeOperations.isEmpty;

  String? get startDate => _startDate;
  String? get endDate => _endDate;
  String? get statusFilter => _statusFilter;
  String? get jenisDarurat => _jenisDarurat;
  String? get idTim => _idTim;

  bool get hasActiveFilter {
    return (_startDate?.isNotEmpty == true) ||
        (_endDate?.isNotEmpty == true) ||
        (_statusFilter?.isNotEmpty == true) ||
        (_jenisDarurat?.isNotEmpty == true) ||
        (_idTim?.isNotEmpty == true);
  }

  /// Sets a filter and triggers a refetch.
  void setFilter({
    String? startDate,
    String? endDate,
    String? status,
    String? jenisDarurat,
    String? idTim,
  }) {
    _startDate = startDate;
    _endDate = endDate;
    _statusFilter = status;
    _jenisDarurat = jenisDarurat;
    _idTim = idTim;
    fetchMonitoring();
  }

  /// Clears all filters and refetches.
  void clearFilters() {
    _startDate = null;
    _endDate = null;
    _statusFilter = null;
    _jenisDarurat = null;
    _idTim = null;
    fetchMonitoring();
  }

  /// Fetches monitoring data from the API.
  Future<void> fetchMonitoring({bool isRefresh = false}) async {
    if (!isRefresh) {
      _status = MonitoringStateStatus.loading;
      _errorMessage = null;
    } else {
      _status = MonitoringStateStatus.refreshing;
    }
    notifyListeners();

    try {
      final data = await _repository.getMonitoring(
        startDate: _startDate,
        endDate: _endDate,
        status: _statusFilter,
        jenisDarurat: _jenisDarurat,
        idTim: _idTim,
      );
      _data = data;
      _status = MonitoringStateStatus.loaded;
      _errorMessage = null;
    } on ApiException catch (e) {
      _status = MonitoringStateStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = MonitoringStateStatus.error;
      _errorMessage = 'Gagal memuat data monitoring: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  /// Resets the controller to initial state.
  void reset() {
    _status = MonitoringStateStatus.initial;
    _data = null;
    _errorMessage = null;
    _startDate = null;
    _endDate = null;
    _statusFilter = null;
    _jenisDarurat = null;
    _idTim = null;
    notifyListeners();
  }
}