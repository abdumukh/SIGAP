import 'package:flutter/foundation.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../data/models/korban_model.dart';
import '../../../data/repositories/korban_repository.dart';

enum KorbanStateStatus {
  initial,
  loading,
  loaded,
  creating,
  deleting,
  success,
  error,
}

/// State controller for managing Korban (Victim) records under a Penanganan.
class KorbanController extends ChangeNotifier {
  final KorbanRepository repository;

  KorbanController({required this.repository});

  KorbanStateStatus _status = KorbanStateStatus.initial;
  List<KorbanModel> _korbanList = [];
  KorbanModel? _selectedKorban;
  String? _errorMessage;
  String? _successMessage;

  KorbanStateStatus get status => _status;
  List<KorbanModel> get korbanList => List.unmodifiable(_korbanList);
  KorbanModel? get selectedKorban => _selectedKorban;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  bool get isLoading => _status == KorbanStateStatus.loading;
  bool get isCreating => _status == KorbanStateStatus.creating;
  bool get isDeleting => _status == KorbanStateStatus.deleting;

  /// Returns list of korban filtered by specific Penanganan ID.
  List<KorbanModel> getKorbanForPenanganan(String idPenanganan) {
    return _korbanList
        .where((k) => k.idPenanganan == idPenanganan)
        .toList();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Fetches all accessible korban records.
  Future<void> fetchKorbanList({bool isRefresh = false}) async {
    if (!isRefresh) {
      _status = KorbanStateStatus.loading;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      _korbanList = await repository.getKorbanList();
      _status = KorbanStateStatus.loaded;
      _errorMessage = null;
    } on ApiException catch (e) {
      _status = KorbanStateStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = KorbanStateStatus.error;
      _errorMessage = 'Terjadi kesalahan saat memuat data korban.';
    } finally {
      notifyListeners();
    }
  }

  /// Fetches single korban details.
  Future<void> fetchKorbanDetail(String id) async {
    _status = KorbanStateStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedKorban = await repository.getKorbanById(id);
      _status = KorbanStateStatus.loaded;
      _errorMessage = null;
    } on ApiException catch (e) {
      _status = KorbanStateStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = KorbanStateStatus.error;
      _errorMessage = 'Gagal memuat detail korban.';
    } finally {
      notifyListeners();
    }
  }

  /// Creates a new korban record.
  Future<KorbanModel?> createKorban({
    required String idPenanganan,
    required String namaKorban,
    required String jenisKelamin,
    required int usia,
    required String kondisi,
    required String statusPenanganan,
    String? note,
  }) async {
    if (isCreating || isDeleting) return null;

    _status = KorbanStateStatus.creating;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final created = await repository.createKorban(
        idPenanganan: idPenanganan,
        namaKorban: namaKorban,
        jenisKelamin: jenisKelamin,
        usia: usia,
        kondisi: kondisi,
        statusPenanganan: statusPenanganan,
        note: note,
      );

      _korbanList.insert(0, created);
      _status = KorbanStateStatus.success;
      _successMessage = 'Data korban berhasil ditambahkan.';
      notifyListeners();
      return created;
    } on ValidationException catch (e) {
      _status = KorbanStateStatus.error;
      _errorMessage = e.firstErrorMessage;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      _status = KorbanStateStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return null;
    } catch (e) {
      _status = KorbanStateStatus.error;
      _errorMessage = 'Gagal menambahkan data korban.';
      notifyListeners();
      return null;
    }
  }

  /// Deletes a korban record.
  Future<bool> deleteKorban(String idKorban) async {
    if (isDeleting || isCreating) return false;

    _status = KorbanStateStatus.deleting;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final success = await repository.deleteKorban(idKorban);
      if (success) {
        _korbanList.removeWhere((k) => k.idKorban == idKorban);
        _status = KorbanStateStatus.success;
        _successMessage = 'Data korban berhasil dihapus.';
        notifyListeners();
        return true;
      } else {
        _status = KorbanStateStatus.error;
        _errorMessage = 'Gagal menghapus data korban.';
        notifyListeners();
        return false;
      }
    } on ApiException catch (e) {
      _status = KorbanStateStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _status = KorbanStateStatus.error;
      _errorMessage = 'Gagal menghapus data korban.';
      notifyListeners();
      return false;
    }
  }
}