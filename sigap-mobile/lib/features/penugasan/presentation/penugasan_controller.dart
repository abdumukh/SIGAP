import 'package:flutter/foundation.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../data/models/penugasan_model.dart';
import '../../../data/repositories/penugasan_repository.dart';

enum PenugasanStateStatus { initial, loading, loaded, submitting, success, error }

/// State controller for Penugasan (Assignment) management.
class PenugasanController extends ChangeNotifier {
  final PenugasanRepository repository;

  PenugasanController({required this.repository});

  PenugasanStateStatus _status = PenugasanStateStatus.initial;
  List<PenugasanModel> _penugasanList = [];
  PenugasanModel? _selectedPenugasan;
  String? _errorMessage;
  String? _successMessage;
  String? _selectedFilter; // null = all, 'menunggu', 'proses', 'selesai', 'ditolak'

  PenugasanStateStatus get status => _status;
  List<PenugasanModel> get penugasanList => List.unmodifiable(_penugasanList);
  PenugasanModel? get selectedPenugasan => _selectedPenugasan;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? get selectedFilter => _selectedFilter;

  bool get isLoading => _status == PenugasanStateStatus.loading;
  bool get isSubmitting => _status == PenugasanStateStatus.submitting;

  List<PenugasanModel> get filteredPenugasanList {
    if (_selectedFilter == null) return _penugasanList;
    return _penugasanList
        .where((p) => p.statusPenugasan == _selectedFilter)
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

  /// Fetches all assignments.
  Future<void> fetchPenugasanList({bool isRefresh = false}) async {
    if (!isRefresh) {
      _status = PenugasanStateStatus.loading;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      _penugasanList = await repository.getPenugasanList();
      _status = PenugasanStateStatus.loaded;
    } on ApiException catch (e) {
      _status = PenugasanStateStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = PenugasanStateStatus.error;
      _errorMessage = 'Terjadi kesalahan saat memuat daftar penugasan.';
    } finally {
      notifyListeners();
    }
  }

  /// Fetches single assignment details.
  Future<void> fetchPenugasanDetail(String idPenugasan) async {
    _status = PenugasanStateStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedPenugasan = await repository.getPenugasanById(idPenugasan);
      _status = PenugasanStateStatus.loaded;
    } on ApiException catch (e) {
      _status = PenugasanStateStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = PenugasanStateStatus.error;
      _errorMessage = 'Gagal memuat detail penugasan.';
    } finally {
      notifyListeners();
    }
  }

  /// Creates a new assignment.
  Future<PenugasanModel?> createPenugasan({
    required String idAlarm,
    required String idTim,
    required String idKetuaTim,
    String? idPetugasArmada,
    String? idArmada,
    String? waktuPenugasan,
    String? note,
  }) async {
    if (isSubmitting) return null;

    _status = PenugasanStateStatus.submitting;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final created = await repository.createPenugasan(
        idAlarm: idAlarm,
        idTim: idTim,
        idKetuaTim: idKetuaTim,
        idPetugasArmada: idPetugasArmada,
        idArmada: idArmada,
        waktuPenugasan: waktuPenugasan,
        note: note,
      );

      _penugasanList.insert(0, created);
      _status = PenugasanStateStatus.success;
      _successMessage = 'Penugasan ${created.idPenugasan} berhasil dibuat.';
      notifyListeners();
      return created;
    } on ApiException catch (e) {
      _status = PenugasanStateStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return null;
    } catch (e) {
      _status = PenugasanStateStatus.error;
      _errorMessage = 'Gagal membuat penugasan.';
      notifyListeners();
      return null;
    }
  }
}
