import 'package:flutter/foundation.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../data/models/logistik_model.dart';
import '../../../data/repositories/logistik_repository.dart';

enum LogistikStateStatus {
  initial,
  loading,
  loaded,
  creating,
  deleting,
  success,
  error,
}

/// State controller for managing Logistik records under a Penanganan.
class LogistikController extends ChangeNotifier {
  final LogistikRepository repository;

  LogistikController({required this.repository});

  LogistikStateStatus _status = LogistikStateStatus.initial;
  List<LogistikModel> _logistikList = [];
  LogistikModel? _selectedLogistik;
  String? _errorMessage;
  String? _successMessage;

  LogistikStateStatus get status => _status;
  List<LogistikModel> get logistikList => List.unmodifiable(_logistikList);
  LogistikModel? get selectedLogistik => _selectedLogistik;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  bool get isLoading => _status == LogistikStateStatus.loading;
  bool get isCreating => _status == LogistikStateStatus.creating;
  bool get isDeleting => _status == LogistikStateStatus.deleting;

  /// Returns list of logistik filtered by specific Penanganan ID.
  List<LogistikModel> getLogistikForPenanganan(String idPenanganan) {
    return _logistikList
        .where((l) => l.idPenanganan == idPenanganan)
        .toList();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Fetches all accessible logistik records.
  Future<void> fetchLogistikList({bool isRefresh = false}) async {
    if (!isRefresh) {
      _status = LogistikStateStatus.loading;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      _logistikList = await repository.getLogistikList();
      _status = LogistikStateStatus.loaded;
      _errorMessage = null;
    } on ApiException catch (e) {
      _status = LogistikStateStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = LogistikStateStatus.error;
      _errorMessage = 'Terjadi kesalahan saat memuat data logistik.';
    } finally {
      notifyListeners();
    }
  }

  /// Fetches single logistik details.
  Future<void> fetchLogistikDetail(String id) async {
    _status = LogistikStateStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedLogistik = await repository.getLogistikById(id);
      _status = LogistikStateStatus.loaded;
      _errorMessage = null;
    } on ApiException catch (e) {
      _status = LogistikStateStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = LogistikStateStatus.error;
      _errorMessage = 'Gagal memuat detail logistik.';
    } finally {
      notifyListeners();
    }
  }

  /// Creates a new logistik record.
  Future<LogistikModel?> createLogistik({
    required String idPenanganan,
    required String namaLogistik,
    required int jumlah,
    required String satuan,
    required String kondisi,
    String? note,
  }) async {
    if (isCreating || isDeleting) return null;

    _status = LogistikStateStatus.creating;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final created = await repository.createLogistik(
        idPenanganan: idPenanganan,
        namaLogistik: namaLogistik,
        jumlah: jumlah,
        satuan: satuan,
        kondisi: kondisi,
        note: note,
      );

      _logistikList.insert(0, created);
      _status = LogistikStateStatus.success;
      _successMessage = 'Data logistik berhasil ditambahkan.';
      notifyListeners();
      return created;
    } on ValidationException catch (e) {
      _status = LogistikStateStatus.error;
      _errorMessage = e.firstErrorMessage;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      _status = LogistikStateStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return null;
    } catch (e) {
      _status = LogistikStateStatus.error;
      _errorMessage = 'Gagal menambahkan data logistik.';
      notifyListeners();
      return null;
    }
  }

  /// Deletes a logistik record.
  Future<bool> deleteLogistik(String idLogistik) async {
    if (isDeleting || isCreating) return false;

    _status = LogistikStateStatus.deleting;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final success = await repository.deleteLogistik(idLogistik);
      if (success) {
        _logistikList.removeWhere((l) => l.idLogistik == idLogistik);
        _status = LogistikStateStatus.success;
        _successMessage = 'Data logistik berhasil dihapus.';
        notifyListeners();
        return true;
      } else {
        _status = LogistikStateStatus.error;
        _errorMessage = 'Gagal menghapus data logistik.';
        notifyListeners();
        return false;
      }
    } on ApiException catch (e) {
      _status = LogistikStateStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _status = LogistikStateStatus.error;
      _errorMessage = 'Gagal menghapus data logistik.';
      notifyListeners();
      return false;
    }
  }
}