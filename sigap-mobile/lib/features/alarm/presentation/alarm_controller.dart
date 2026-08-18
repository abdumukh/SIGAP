import 'package:flutter/material.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../data/models/alarm_model.dart';
import '../../../data/repositories/alarm_repository.dart';

enum AlarmStateStatus {
  initial,
  loading,
  loaded,
  submitting,
  success,
  error,
}

/// Reactive controller for managing alarm list, details, creation, and status transitions.
class AlarmController extends ChangeNotifier {
  final AlarmRepository _repository;

  AlarmStateStatus _status = AlarmStateStatus.initial;
  List<AlarmModel> _alarms = [];
  AlarmModel? _selectedAlarm;
  String? _errorMessage;
  String? _successMessage;
  String? _selectedFilter; // null = all, 'menunggu', 'diverifikasi', 'ditolak', 'selesai'

  AlarmController({AlarmRepository? repository})
      : _repository = repository ?? AlarmRepository();

  // Getters
  AlarmStateStatus get status => _status;
  List<AlarmModel> get alarms => _alarms;
  AlarmModel? get selectedAlarm => _selectedAlarm;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? get selectedFilter => _selectedFilter;

  bool get isLoading => _status == AlarmStateStatus.loading;
  bool get isSubmitting => _status == AlarmStateStatus.submitting;

  /// Returns filtered list of alarms based on [_selectedFilter].
  List<AlarmModel> get filteredAlarms {
    if (_selectedFilter == null || _selectedFilter!.isEmpty || _selectedFilter == 'all') {
      return _alarms;
    }
    return _alarms.where((a) => a.statusAlarm.toLowerCase() == _selectedFilter!.toLowerCase()).toList();
  }

  void setFilter(String? filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  /// Fetches alarm list.
  Future<void> fetchAlarms({bool isRefresh = false}) async {
    if (!isRefresh) {
      _status = AlarmStateStatus.loading;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final list = await _repository.getAlarms();
      _alarms = list;
      _status = AlarmStateStatus.loaded;
      _errorMessage = null;
    } on ApiException catch (e) {
      _status = AlarmStateStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = AlarmStateStatus.error;
      _errorMessage = 'Gagal memuat daftar alarm: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  /// Fetches single alarm detail.
  Future<void> fetchAlarmDetail(String id) async {
    _status = AlarmStateStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final alarm = await _repository.getAlarmById(id);
      _selectedAlarm = alarm;
      _status = AlarmStateStatus.loaded;
      _errorMessage = null;
    } on ApiException catch (e) {
      _status = AlarmStateStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = AlarmStateStatus.error;
      _errorMessage = 'Gagal memuat detail alarm: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  /// Creates a new alarm report (Masyarakat).
  Future<AlarmModel?> createAlarm({
    required String jenisDarurat,
    required double latitude,
    required double longitude,
    String? cuaca,
    String? laluLintas,
  }) async {
    _status = AlarmStateStatus.submitting;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final newAlarm = await _repository.createAlarm(
        jenisDarurat: jenisDarurat,
        latitude: latitude,
        longitude: longitude,
        cuaca: cuaca,
        laluLintas: laluLintas,
      );

      _alarms.insert(0, newAlarm);
      _selectedAlarm = newAlarm;
      _status = AlarmStateStatus.success;
      _successMessage = 'Laporan alarm darurat berhasil dikirim!';
      notifyListeners();
      return newAlarm;
    } on ValidationException catch (e) {
      _status = AlarmStateStatus.error;
      _errorMessage = e.firstErrorMessage;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      _status = AlarmStateStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return null;
    } catch (e) {
      _status = AlarmStateStatus.error;
      _errorMessage = 'Gagal mengirim alarm: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  /// Verifies an alarm (Admin/Staff).
  Future<bool> verifyAlarm(String id) async {
    _status = AlarmStateStatus.submitting;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.verifyAlarm(id);
      _updateLocalAlarm(updated);
      _status = AlarmStateStatus.success;
      _successMessage = 'Alarm berhasil diverifikasi.';
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _status = AlarmStateStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _status = AlarmStateStatus.error;
      _errorMessage = 'Gagal memverifikasi alarm: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Rejects an alarm (Admin/Staff).
  Future<bool> rejectAlarm(String id) async {
    _status = AlarmStateStatus.submitting;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.rejectAlarm(id);
      _updateLocalAlarm(updated);
      _status = AlarmStateStatus.success;
      _successMessage = 'Alarm berhasil ditolak.';
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _status = AlarmStateStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _status = AlarmStateStatus.error;
      _errorMessage = 'Gagal menolak alarm: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Completes an alarm (Admin/Staff).
  Future<bool> completeAlarm(String id) async {
    _status = AlarmStateStatus.submitting;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.completeAlarm(id);
      _updateLocalAlarm(updated);
      _status = AlarmStateStatus.success;
      _successMessage = 'Alarm berhasil diselesaikan.';
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _status = AlarmStateStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _status = AlarmStateStatus.error;
      _errorMessage = 'Gagal menyelesaikan alarm: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  void _updateLocalAlarm(AlarmModel updated) {
    final index = _alarms.indexWhere((a) => a.idAlarm == updated.idAlarm);
    if (index != -1) {
      _alarms[index] = updated;
    }
    if (_selectedAlarm?.idAlarm == updated.idAlarm) {
      _selectedAlarm = updated;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
