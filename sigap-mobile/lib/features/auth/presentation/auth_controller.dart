import 'package:flutter/material.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Reactive controller managing authentication state across the application.
class AuthController extends ChangeNotifier {
  final AuthRepository _repository;

  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;

  AuthController({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// Checks stored session upon app startup.
  Future<void> checkAuthStatus() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        _status = AuthStatus.authenticated;
      } else {
        _currentUser = null;
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      // Network or other transient error on splash
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      if (e is ApiException) {
        _errorMessage = e.message;
      }
    } finally {
      notifyListeners();
    }
  }

  /// Performs user login with email & password.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _repository.login(
        email: email,
        password: password,
      );
      _currentUser = user;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on ValidationException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.firstErrorMessage;
      notifyListeners();
      return false;
    } on ApiException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Logs out the user and clears state.
  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      await _repository.logout();
    } finally {
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Clears any active error message.
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}
