import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure token & user session storage using [FlutterSecureStorage].
/// Stores Sanctum Bearer tokens and cached user identity safely in Android Keystore / iOS Keychain.
class AuthStorage {
  final FlutterSecureStorage _storage;

  AuthStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
            );

  static const String _keyToken = 'sigap_auth_token';
  static const String _keyActor = 'sigap_auth_actor';
  static const String _keyUser = 'sigap_auth_user';

  /// Saves Sanctum plain-text token.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  /// Retrieves stored token, or null if not present.
  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  /// Checks whether a valid token exists in storage.
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.trim().isNotEmpty;
  }

  /// Deletes the authentication token.
  Future<void> deleteToken() async {
    await _storage.delete(key: _keyToken);
  }

  /// Saves the resolved actor string (masyarakat, admin, ketua_tim, petugas).
  Future<void> saveActor(String actor) async {
    await _storage.write(key: _keyActor, value: actor);
  }

  /// Retrieves the saved actor string.
  Future<String?> getActor() async {
    return await _storage.read(key: _keyActor);
  }

  /// Saves raw JSON string of cached user profile.
  Future<void> saveUserData(String userJson) async {
    await _storage.write(key: _keyUser, value: userJson);
  }

  /// Retrieves cached user profile JSON string.
  Future<String?> getUserData() async {
    return await _storage.read(key: _keyUser);
  }

  /// Clears all stored auth data (token, actor, user).
  Future<void> clearAll() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyActor);
    await _storage.delete(key: _keyUser);
  }
}
