import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../storage/auth_storage.dart';
import 'api_exceptions.dart';

/// Centralized HTTP client powered by [Dio].
/// Automatically attaches Sanctum Bearer tokens from [AuthStorage]
/// and normalizes backend error responses into typed [ApiException]s.
class ApiClient {
  final Dio _dio;
  final AuthStorage _authStorage;

  ApiClient({
    Dio? dio,
    AuthStorage? authStorage,
  })  : _authStorage = authStorage ?? AuthStorage(),
        _dio = dio ?? Dio() {
    _initDio();
  }

  void _initDio() {
    _dio.options = BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Dynamically update baseUrl if user changed it in settings
          options.baseUrl = ApiConfig.baseUrl;

          // Automatically inject Sanctum Bearer token if present
          final token = await _authStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  /// Handles Dio exceptions and converts them into structured [ApiException]s.
  ApiException _handleDioError(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode;
    final data = response?.data;

    // Check if error is network-related (timeout, no connection, refusal)
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return NetworkException(
        message: 'Tidak dapat terhubung ke server SIGAP (${ApiConfig.baseUrl}). '
            'Pastikan backend aktif dan device terhubung ke jaringan yang sama.',
        rawData: error,
      );
    }

    String message = 'Terjadi kesalahan sistem.';
    if (data is Map<String, dynamic>) {
      if (data.containsKey('message') && data['message'] != null) {
        message = data['message'].toString();
      }
    }

    switch (statusCode) {
      case 401:
        return UnauthorizedException(message: message, rawData: data);
      case 403:
        return ForbiddenException(message: message, rawData: data);
      case 404:
        return NotFoundException(message: message, rawData: data);
      case 422:
        final Map<String, List<String>> errorsMap = {};
        if (data is Map<String, dynamic> && data['errors'] is Map) {
          final rawErrors = data['errors'] as Map<String, dynamic>;
          rawErrors.forEach((key, val) {
            if (val is List) {
              errorsMap[key] = val.map((e) => e.toString()).toList();
            } else if (val is String) {
              errorsMap[key] = [val];
            }
          });
        }
        return ValidationException(
          message: message,
          errors: errorsMap,
          rawData: data,
        );
      case 500:
      case 502:
      case 503:
        return ServerException(message: message, rawData: data);
      default:
        return ApiException(
          message: message,
          statusCode: statusCode,
          rawData: data,
        );
    }
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
}
