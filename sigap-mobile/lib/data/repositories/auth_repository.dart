import 'dart:convert';
import '../../core/network/api_exceptions.dart';
import '../../core/storage/auth_storage.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Repository orchestrating authentication business logic and secure token persistence.
class AuthRepository {
  final AuthService _service;
  final AuthStorage _storage;

  AuthRepository({
    AuthService? service,
    AuthStorage? storage,
  })  : _service = service ?? AuthService(),
        _storage = storage ?? AuthStorage();

  /// Logs in user, saves Sanctum token & actor to secure storage, and returns [UserModel].
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _service.login(
      email: email,
      password: password,
    );

    if (response.token != null && response.token!.isNotEmpty) {
      await _storage.saveToken(response.token!);
    }

    await _storage.saveActor(response.actor);
    await _storage.saveUserData(jsonEncode(response.user.toJson()));

    return response.user;
  }

  /// Checks if token exists and verifies validity by calling `/api/auth/me`.
  /// Returns the validated [UserModel] or null if not authenticated / expired.
  Future<UserModel?> getCurrentUser() async {
    final hasToken = await _storage.hasToken();
    if (!hasToken) {
      return null;
    }

    try {
      final response = await _service.getProfile();
      await _storage.saveActor(response.actor);
      await _storage.saveUserData(jsonEncode(response.user.toJson()));
      return response.user;
    } on UnauthorizedException {
      // Token is invalid/revoked on server, clean local storage
      await _storage.clearAll();
      return null;
    } catch (_) {
      // If network fails but cached user is present, try reading local cache if necessary,
      // but re-throw or return null based on strict session policy.
      rethrow;
    }
  }

  /// Logs out user from backend and purges local secure storage.
  Future<void> logout() async {
    try {
      await _service.logout();
    } catch (_) {
      // Ignore API logout error (e.g. if already expired or offline)
    } finally {
      await _storage.clearAll();
    }
  }

  /// Checks if a token is locally stored.
  Future<bool> hasStoredToken() async {
    return await _storage.hasToken();
  }

  /// Gets stored actor string directly from storage.
  Future<String?> getStoredActor() async {
    return await _storage.getActor();
  }
}
