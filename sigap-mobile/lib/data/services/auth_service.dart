import '../../core/config/api_config.dart';
import '../../core/network/api_client.dart';
import '../models/auth_response_model.dart';

/// Low-level HTTP communication service for Authentication API endpoints.
class AuthService {
  final ApiClient _client;

  AuthService({ApiClient? client}) : _client = client ?? ApiClient();

  /// Authenticates user against `/api/auth/login`.
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      ApiConfig.loginEndpoint,
      data: {
        'email': email.trim(),
        'password': password,
      },
    );

    final rawData = response.data as Map<String, dynamic>;
    return AuthResponseModel.fromJson(rawData);
  }

  /// Fetches current authenticated user profile from `/api/auth/me`.
  Future<AuthResponseModel> getProfile() async {
    final response = await _client.get(ApiConfig.meEndpoint);
    final rawData = response.data as Map<String, dynamic>;
    return AuthResponseModel.fromJson(rawData);
  }

  /// Revokes active Sanctum token via `/api/auth/logout`.
  Future<void> logout() async {
    await _client.post(ApiConfig.logoutEndpoint);
  }
}
