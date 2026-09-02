import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;
import '../../../core/network/api_exceptions.dart';
import '../../../data/models/notifikasi_model.dart';
import '../../../data/repositories/notifikasi_repository.dart';

class NotifikasiController extends ChangeNotifier {
  final NotifikasiRepository _repository;
  bool _isLoading = false;
  String? _errorMessage;
  List<NotifikasiModel> _notifikasiList = [];
  NotifikasiModel? _selectedNotifikasi;
  String? _selectedFilter;
  int _unreadCount = 0;

  NotifikasiController({NotifikasiRepository? repository})
      : _repository = repository ?? NotifikasiRepository();

  bool get isLoading => _isLoading;
  List<NotifikasiModel> get notifikasiList => List.unmodifiable(_notifikasiList);
  NotifikasiModel? get selectedNotifikasi => _selectedNotifikasi;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null && _notifikasiList.isEmpty;
  int get unreadCount => _unreadCount;

  List<NotifikasiModel> get filteredNotifikasiList {
    if (_selectedFilter == null || _selectedFilter!.isEmpty) {
      return _notifikasiList;
    }
    return _notifikasiList
        .where((n) => n.type == _selectedFilter)
        .toList();
  }

  void setFilter(String? filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchNotifikasiList() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifikasiList = await _repository.getNotifikasiList();
      _unreadCount = _notifikasiList.where((n) => n.isUnread).length;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } on ApiException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal memuat notifikasi: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> fetchNotifikasiById(String idNotifikasi) async {
    _selectedNotifikasi = await _repository.getNotifikasiById(idNotifikasi);
    notifyListeners();
  }

  Future<void> markAsRead(String idNotifikasi) async {
    try {
      await _repository.markAsRead(idNotifikasi);
      await fetchNotifikasiList();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal menandai notifikasi: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      await fetchNotifikasiList();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal menandai semua notifikasi: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> refreshUnreadCount() async {
    try {
      _unreadCount = await _repository.getUnreadCount();
      notifyListeners();
    } catch (e) {
      // Ignore count errors
    }
  }
}