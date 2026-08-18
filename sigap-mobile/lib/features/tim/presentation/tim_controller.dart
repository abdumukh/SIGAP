import 'package:flutter/foundation.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../data/models/tim_model.dart';
import '../../../data/repositories/tim_repository.dart';

enum TimStateStatus { initial, loading, loaded, submitting, success, error }

/// State controller for Tim management (Admin operations).
class TimController extends ChangeNotifier {
  final TimRepository repository;

  TimController({required this.repository});

  TimStateStatus _status = TimStateStatus.initial;
  List<TimModel> _timList = [];
  TimModel? _selectedTim;
  String? _errorMessage;
  String? _successMessage;
  String? _selectedFilter; // null = all, 'aktif', 'nonaktif'

  TimStateStatus get status => _status;
  List<TimModel> get timList => List.unmodifiable(_timList);
  TimModel? get selectedTim => _selectedTim;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? get selectedFilter => _selectedFilter;

  bool get isLoading => _status == TimStateStatus.loading;
  bool get isSubmitting => _status == TimStateStatus.submitting;

  List<TimModel> get filteredTimList {
    if (_selectedFilter == null) return _timList;
    return _timList.where((t) => t.statusTim == _selectedFilter).toList();
  }

  void setFilter(String? filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Fetches all teams from backend.
  Future<void> fetchTimList({bool isRefresh = false}) async {
    if (!isRefresh) {
      _status = TimStateStatus.loading;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      _timList = await repository.getTimList();
      _status = TimStateStatus.loaded;
    } on ApiException catch (e) {
      _status = TimStateStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = TimStateStatus.error;
      _errorMessage = 'Terjadi kesalahan saat memuat data tim.';
    } finally {
      notifyListeners();
    }
  }

  /// Fetches single team details with members.
  Future<void> fetchTimDetail(String idTim) async {
    _status = TimStateStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedTim = await repository.getTimById(idTim);
      _status = TimStateStatus.loaded;
    } on ApiException catch (e) {
      _status = TimStateStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = TimStateStatus.error;
      _errorMessage = 'Gagal memuat detail tim.';
    } finally {
      notifyListeners();
    }
  }

  /// Creates a new team.
  Future<TimModel?> createTim({
    required String namaTim,
    String? note,
    String? statusTim,
  }) async {
    if (isSubmitting) return null;

    _status = TimStateStatus.submitting;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final created = await repository.createTim(
        namaTim: namaTim,
        note: note,
        statusTim: statusTim,
      );
      _timList.insert(0, created);
      _status = TimStateStatus.success;
      _successMessage = 'Tim "${created.namaTim}" berhasil dibuat.';
      notifyListeners();
      return created;
    } on ApiException catch (e) {
      _status = TimStateStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return null;
    } catch (e) {
      _status = TimStateStatus.error;
      _errorMessage = 'Gagal membuat tim.';
      notifyListeners();
      return null;
    }
  }

  /// Updates existing team.
  Future<bool> updateTim(
    String idTim, {
    String? namaTim,
    String? note,
    String? statusTim,
  }) async {
    if (isSubmitting) return false;

    _status = TimStateStatus.submitting;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final updated = await repository.updateTim(
        idTim,
        namaTim: namaTim,
        note: note,
        statusTim: statusTim,
      );

      final index = _timList.indexWhere((t) => t.idTim == idTim);
      if (index != -1) {
        _timList[index] = updated;
      }
      if (_selectedTim?.idTim == idTim) {
        _selectedTim = updated;
      }

      _status = TimStateStatus.success;
      _successMessage = 'Data tim berhasil diperbarui.';
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _status = TimStateStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _status = TimStateStatus.error;
      _errorMessage = 'Gagal memperbarui tim.';
      notifyListeners();
      return false;
    }
  }

  /// Deactivates / soft-deletes a team.
  Future<bool> deleteTim(String idTim) async {
    if (isSubmitting) return false;

    _status = TimStateStatus.submitting;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final deactivated = await repository.deleteTim(idTim);

      final index = _timList.indexWhere((t) => t.idTim == idTim);
      if (index != -1) {
        _timList[index] = deactivated;
      }
      if (_selectedTim?.idTim == idTim) {
        _selectedTim = deactivated;
      }

      _status = TimStateStatus.success;
      _successMessage = 'Tim berhasil dinonaktifkan.';
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _status = TimStateStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _status = TimStateStatus.error;
      _errorMessage = 'Gagal menonaktifkan tim.';
      notifyListeners();
      return false;
    }
  }
}
