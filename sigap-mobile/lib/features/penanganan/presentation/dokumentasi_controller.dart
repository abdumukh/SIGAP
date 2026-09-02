import 'package:flutter/foundation.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../data/models/dokumentasi_model.dart';
import '../../../data/repositories/dokumentasi_repository.dart';

enum DokumentasiStateStatus {
  initial,
  loading,
  loaded,
  uploading,
  deleting,
  success,
  error,
}

/// State controller for managing Dokumentasi Lapangan (Field Documentation & Evidence).
class DokumentasiController extends ChangeNotifier {
  final DokumentasiRepository repository;

  DokumentasiController({required this.repository});

  DokumentasiStateStatus _status = DokumentasiStateStatus.initial;
  List<DokumentasiModel> _dokumentasiList = [];
  DokumentasiModel? _selectedDokumentasi;
  String? _errorMessage;
  String? _successMessage;

  DokumentasiStateStatus get status => _status;
  List<DokumentasiModel> get dokumentasiList => List.unmodifiable(_dokumentasiList);
  DokumentasiModel? get selectedDokumentasi => _selectedDokumentasi;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  bool get isLoading => _status == DokumentasiStateStatus.loading;
  bool get isUploading => _status == DokumentasiStateStatus.uploading;
  bool get isDeleting => _status == DokumentasiStateStatus.deleting;

  /// Returns list of documentation filtered by specific Penanganan ID.
  List<DokumentasiModel> getDokumentasiForPenanganan(String idPenanganan) {
    return _dokumentasiList
        .where((doc) => doc.idPenanganan == idPenanganan)
        .toList();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Fetches all accessible documentation records.
  Future<void> fetchDokumentasiList({bool isRefresh = false}) async {
    if (!isRefresh) {
      _status = DokumentasiStateStatus.loading;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      _dokumentasiList = await repository.getDokumentasiList();
      _status = DokumentasiStateStatus.loaded;
      _errorMessage = null;
    } on ApiException catch (e) {
      _status = DokumentasiStateStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = DokumentasiStateStatus.error;
      _errorMessage = 'Terjadi kesalahan saat memuat dokumentasi.';
    } finally {
      notifyListeners();
    }
  }

  /// Fetches single documentation item details.
  Future<void> fetchDokumentasiDetail(String id) async {
    _status = DokumentasiStateStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedDokumentasi = await repository.getDokumentasiById(id);
      _status = DokumentasiStateStatus.loaded;
      _errorMessage = null;
    } on ApiException catch (e) {
      _status = DokumentasiStateStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = DokumentasiStateStatus.error;
      _errorMessage = 'Gagal memuat detail dokumentasi.';
    } finally {
      notifyListeners();
    }
  }

  /// Uploads new documentation item.
  Future<DokumentasiModel?> uploadDokumentasi({
    required String idPenanganan,
    required String jenisDokumentasi,
    required dynamic file,
    String? note,
  }) async {
    if (isUploading || isDeleting) return null;

    _status = DokumentasiStateStatus.uploading;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final created = await repository.createDokumentasi(
        idPenanganan: idPenanganan,
        jenisDokumentasi: jenisDokumentasi,
        fileDokumentasi: file,
        note: note,
      );

      _dokumentasiList.insert(0, created);
      _status = DokumentasiStateStatus.success;
      _successMessage = 'Dokumentasi berhasil diunggah.';
      notifyListeners();
      return created;
    } on ValidationException catch (e) {
      _status = DokumentasiStateStatus.error;
      _errorMessage = e.firstErrorMessage;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      _status = DokumentasiStateStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return null;
    } catch (e) {
      _status = DokumentasiStateStatus.error;
      _errorMessage = 'Gagal mengunggah dokumentasi.';
      notifyListeners();
      return null;
    }
  }

  /// Deletes a documentation record.
  Future<bool> deleteDokumentasi(String idDokumentasi) async {
    if (isDeleting || isUploading) return false;

    _status = DokumentasiStateStatus.deleting;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final success = await repository.deleteDokumentasi(idDokumentasi);
      if (success) {
        _dokumentasiList.removeWhere((doc) => doc.idDokumentasi == idDokumentasi);
        _status = DokumentasiStateStatus.success;
        _successMessage = 'Dokumentasi berhasil dihapus.';
        notifyListeners();
        return true;
      } else {
        _status = DokumentasiStateStatus.error;
        _errorMessage = 'Gagal menghapus dokumentasi.';
        notifyListeners();
        return false;
      }
    } on ApiException catch (e) {
      _status = DokumentasiStateStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _status = DokumentasiStateStatus.error;
      _errorMessage = 'Gagal menghapus dokumentasi.';
      notifyListeners();
      return false;
    }
  }
}
