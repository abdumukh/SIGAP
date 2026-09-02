import 'package:flutter/foundation.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../data/models/laporan_model.dart';
import '../../../data/repositories/laporan_repository.dart';

enum LaporanStateStatus {
  initial,
  loading,
  loaded,
  refreshing,
  error,
}

/// Reactive controller for Laporan data (rekap per type with filters).
class LaporanController extends ChangeNotifier {
  final LaporanRepository _repository;

  LaporanStateStatus _status = LaporanStateStatus.initial;
  LaporanModel? _data;
  String? _errorMessage;

  // Current filter state
  LaporanFilter _currentFilter = const LaporanFilter();

  LaporanController({LaporanRepository? repository})
      : _repository = repository ?? LaporanRepository();

  // Getters
  LaporanStateStatus get status => _status;
  LaporanModel? get data => _data;
  String? get errorMessage => _errorMessage;
  LaporanFilter get currentFilter => _currentFilter;

  bool get isLoading => _status == LaporanStateStatus.loading;
  bool get isRefreshing => _status == LaporanStateStatus.refreshing;
  bool get isLoaded => _status == LaporanStateStatus.loaded;
  bool get hasError => _status == LaporanStateStatus.error;
  bool get isEmpty => _data == null || _data!.items.isEmpty;

  /// Fetches laporan for the given type and filters.
  Future<void> fetchLaporan({
    required String type,
    String? startDate,
    String? endDate,
    String? status,
    String? jenisDarurat,
    String? idTim,
    String? role,
    bool isRefresh = false,
  }) async {
    _currentFilter = LaporanFilter(
      type: type,
      startDate: startDate,
      endDate: endDate,
      status: status,
      jenisDarurat: jenisDarurat,
      idTim: idTim,
      role: role,
    );

    if (!isRefresh) {
      _status = LaporanStateStatus.loading;
      _errorMessage = null;
    } else {
      _status = LaporanStateStatus.refreshing;
    }
    notifyListeners();

    try {
      final data = await _repository.getLaporan(filter: _currentFilter);
      _data = data;
      _status = LaporanStateStatus.loaded;
      _errorMessage = null;
    } on ApiException catch (e) {
      _status = LaporanStateStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = LaporanStateStatus.error;
      _errorMessage = 'Gagal memuat laporan: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  /// Clears all filters and refetches using the current type.
  Future<void> clearFilters() async {
    await fetchLaporan(type: _currentFilter.type ?? 'alarm');
  }

  /// Resets the controller to initial state.
  void reset() {
    _status = LaporanStateStatus.initial;
    _data = null;
    _errorMessage = null;
    _currentFilter = const LaporanFilter();
    notifyListeners();
  }
}