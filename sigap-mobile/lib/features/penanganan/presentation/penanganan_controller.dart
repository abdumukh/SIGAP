import 'package:flutter/foundation.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../data/models/penanganan_model.dart';
import '../../../data/repositories/penanganan_repository.dart';

enum PenangananStateStatus {
  initial,
  loading,
  loaded,
  submitting,
  updating,
  success,
  error,
}

/// State controller for managing Penanganan (Emergency Response Handling).
class PenangananController extends ChangeNotifier {
  final PenangananRepository repository;

  PenangananController({required this.repository});

  PenangananStateStatus _status = PenangananStateStatus.initial;
  List<PenangananModel> _penangananList = [];
  PenangananModel? _selectedPenanganan;
  String? _errorMessage;
  String? _successMessage;
  String? _selectedFilter; // null = all, 'menuju_lokasi', 'di_lokasi', 'selesai'

  PenangananStateStatus get status => _status;
  List<PenangananModel> get penangananList => List.unmodifiable(_penangananList);
  PenangananModel? get selectedPenanganan => _selectedPenanganan;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? get selectedFilter => _selectedFilter;

  bool get isLoading => _status == PenangananStateStatus.loading;
  bool get isSubmitting => _status == PenangananStateStatus.submitting;
  bool get isUpdating => _status == PenangananStateStatus.updating;

  List<PenangananModel> get filteredPenangananList {
    if (_selectedFilter == null || _selectedFilter!.isEmpty || _selectedFilter == 'all') {
      return _penangananList;
    }
    return _penangananList
        .where((p) => p.statusPenanganan.toLowerCase() == _selectedFilter!.toLowerCase())
        .toList();
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

  /// Fetches all accessible Penanganan records.
  Future<void> fetchPenangananList({bool isRefresh = false}) async {
    if (!isRefresh) {
      _status = PenangananStateStatus.loading;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      _penangananList = await repository.getPenangananList();
      _status = PenangananStateStatus.loaded;
      _errorMessage = null;
    } on ApiException catch (e) {
      _status = PenangananStateStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = PenangananStateStatus.error;
      _errorMessage = 'Terjadi kesalahan saat memuat daftar penanganan.';
    } finally {
      notifyListeners();
    }
  }

  /// Fetches single Penanganan details.
  Future<void> fetchPenangananDetail(String id) async {
    _status = PenangananStateStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedPenanganan = await repository.getPenangananById(id);
      _status = PenangananStateStatus.loaded;
      _errorMessage = null;
    } on ApiException catch (e) {
      _status = PenangananStateStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = PenangananStateStatus.error;
      _errorMessage = 'Gagal memuat detail penanganan.';
    } finally {
      notifyListeners();
    }
  }

  /// Creates a new Penanganan record from an assigned Penugasan.
  Future<PenangananModel?> createPenanganan({
    required String idPenugasan,
    String? note,
  }) async {
    if (isSubmitting || isUpdating) return null;

    _status = PenangananStateStatus.submitting;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final created = await repository.createPenanganan(
        idPenugasan: idPenugasan,
        note: note,
      );

      _penangananList.insert(0, created);
      _selectedPenanganan = created;
      _status = PenangananStateStatus.success;
      _successMessage = 'Penanganan ${created.idPenanganan} berhasil dimulai.';
      notifyListeners();
      return created;
    } on ValidationException catch (e) {
      _status = PenangananStateStatus.error;
      _errorMessage = e.firstErrorMessage;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      _status = PenangananStateStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return null;
    } catch (e) {
      _status = PenangananStateStatus.error;
      _errorMessage = 'Gagal membuat penanganan.';
      notifyListeners();
      return null;
    }
  }

  /// Updates status of Penanganan (menuju_lokasi -> di_lokasi -> selesai).
  Future<PenangananModel?> updateStatus(
    String id, {
    required String targetStatus,
    String? note,
  }) async {
    if (isUpdating || isSubmitting) return null;

    // Client-side pre-validation if we have selected penanganan
    if (_selectedPenanganan != null && _selectedPenanganan!.idPenanganan == id) {
      final current = _selectedPenanganan!.statusPenanganan;
      if (current == 'selesai') {
        _status = PenangananStateStatus.error;
        _errorMessage = 'Penanganan yang sudah selesai tidak dapat diubah kembali.';
        notifyListeners();
        return null;
      }

      if (current == 'menuju_lokasi' && targetStatus != 'di_lokasi') {
        _status = PenangananStateStatus.error;
        _errorMessage = "Transisi status dari '$current' ke '$targetStatus' tidak valid.";
        notifyListeners();
        return null;
      }

      if (current == 'di_lokasi' && targetStatus != 'selesai') {
        _status = PenangananStateStatus.error;
        _errorMessage = "Transisi status dari '$current' ke '$targetStatus' tidak valid.";
        notifyListeners();
        return null;
      }
    }

    _status = PenangananStateStatus.updating;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final updated = await repository.updatePenangananStatus(
        id,
        statusPenanganan: targetStatus,
        note: note,
      );

      _updateLocalPenanganan(updated);
      _status = PenangananStateStatus.success;
      _successMessage = 'Status penanganan berhasil diperbarui ke ${updated.statusDisplay}.';
      notifyListeners();
      return updated;
    } on ValidationException catch (e) {
      _status = PenangananStateStatus.error;
      _errorMessage = e.firstErrorMessage;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      _status = PenangananStateStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return null;
    } catch (e) {
      _status = PenangananStateStatus.error;
      _errorMessage = 'Gagal memperbarui status penanganan.';
      notifyListeners();
      return null;
    }
  }

  void _updateLocalPenanganan(PenangananModel updated) {
    final index = _penangananList.indexWhere((p) => p.idPenanganan == updated.idPenanganan);
    if (index != -1) {
      _penangananList[index] = updated;
    }
    if (_selectedPenanganan?.idPenanganan == updated.idPenanganan) {
      _selectedPenanganan = updated;
    }
  }
}
