import 'package:flutter/foundation.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../data/models/anggota_tim_model.dart';
import '../../../data/repositories/anggota_tim_repository.dart';

enum AnggotaStateStatus { initial, loading, loaded, submitting, success, error }

/// State controller for managing team members within a team.
class AnggotaTimController extends ChangeNotifier {
  final AnggotaTimRepository repository;

  AnggotaTimController({required this.repository});

  AnggotaStateStatus _status = AnggotaStateStatus.initial;
  List<AnggotaTimModel> _members = [];
  String? _errorMessage;
  String? _successMessage;

  AnggotaStateStatus get status => _status;
  List<AnggotaTimModel> get members => List.unmodifiable(_members);
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  bool get isLoading => _status == AnggotaStateStatus.loading;
  bool get isSubmitting => _status == AnggotaStateStatus.submitting;

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Fetches all members of a team.
  Future<void> fetchMembers(String idTim) async {
    _status = AnggotaStateStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _members = await repository.getAnggota(idTim);
      _status = AnggotaStateStatus.loaded;
    } on ApiException catch (e) {
      _status = AnggotaStateStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = AnggotaStateStatus.error;
      _errorMessage = 'Gagal memuat daftar anggota tim.';
    } finally {
      notifyListeners();
    }
  }

  /// Adds a member to a team.
  Future<bool> addMember(
    String idTim, {
    required String idPetugas,
    String? tanggalMasuk,
    String? statusAnggota,
  }) async {
    if (isSubmitting) return false;

    _status = AnggotaStateStatus.submitting;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final newMember = await repository.addAnggota(
        idTim,
        idPetugas: idPetugas,
        tanggalMasuk: tanggalMasuk,
        statusAnggota: statusAnggota,
      );

      _members.insert(0, newMember);
      _status = AnggotaStateStatus.success;
      _successMessage = 'Anggota tim berhasil ditambahkan.';
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _status = AnggotaStateStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _status = AnggotaStateStatus.error;
      _errorMessage = 'Gagal menambahkan anggota tim.';
      notifyListeners();
      return false;
    }
  }

  /// Updates status of a team member.
  Future<bool> updateMemberStatus(
    String idTim,
    String idAnggota, {
    required String statusAnggota,
  }) async {
    if (isSubmitting) return false;

    _status = AnggotaStateStatus.submitting;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final updated = await repository.updateAnggota(
        idTim,
        idAnggota,
        statusAnggota: statusAnggota,
      );

      final index = _members.indexWhere((m) => m.idAnggotaTim == idAnggota);
      if (index != -1) {
        _members[index] = updated;
      }

      _status = AnggotaStateStatus.success;
      _successMessage = 'Status anggota berhasil diubah.';
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _status = AnggotaStateStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _status = AnggotaStateStatus.error;
      _errorMessage = 'Gagal memperbarui status anggota.';
      notifyListeners();
      return false;
    }
  }

  /// Deactivates / removes a team member.
  Future<bool> removeMember(String idTim, String idAnggota) async {
    if (isSubmitting) return false;

    _status = AnggotaStateStatus.submitting;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final removed = await repository.removeAnggota(idTim, idAnggota);

      final index = _members.indexWhere((m) => m.idAnggotaTim == idAnggota);
      if (index != -1) {
        _members[index] = removed;
      }

      _status = AnggotaStateStatus.success;
      _successMessage = 'Anggota tim berhasil dinonaktifkan.';
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _status = AnggotaStateStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _status = AnggotaStateStatus.error;
      _errorMessage = 'Gagal menonaktifkan anggota tim.';
      notifyListeners();
      return false;
    }
  }
}
