/// Base exception class for all SIGAP API communication errors.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic rawData;

  const ApiException({
    required this.message,
    this.statusCode,
    this.rawData,
  });

  @override
  String toString() => message;
}

/// 401 Unauthorized: token missing, expired, or invalid credentials.
class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Sesi telah berakhir atau kredensial salah. Silakan login kembali.',
    super.statusCode = 401,
    super.rawData,
  });
}

/// 403 Forbidden: user does not have permission for the requested action.
class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.message = 'Akses ditolak. Anda tidak memiliki izin untuk fitur ini.',
    super.statusCode = 403,
    super.rawData,
  });
}

/// 422 Validation Error: form field validation failed in Laravel.
class ValidationException extends ApiException {
  final Map<String, List<String>> errors;

  ValidationException({
    super.message = 'Data yang dikirimkan tidak valid.',
    super.statusCode = 422,
    this.errors = const {},
    super.rawData,
  });

  /// Extracts the first validation error message from the errors map if available.
  String get firstErrorMessage {
    if (errors.isNotEmpty) {
      final firstKey = errors.keys.first;
      final errorList = errors[firstKey];
      if (errorList != null && errorList.isNotEmpty) {
        return errorList.first;
      }
    }
    return message;
  }
}

/// 404 Not Found: resource does not exist.
class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'Data yang dicari tidak ditemukan.',
    super.statusCode = 404,
    super.rawData,
  });
}

/// 500 Internal Server Error: backend server error.
class ServerException extends ApiException {
  const ServerException({
    super.message = 'Terjadi kesalahan pada server backend. Silakan coba lagi nanti.',
    super.statusCode = 500,
    super.rawData,
  });
}

/// Network / Connectivity failure: host unreachable, timeout, offline.
class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'Gagal terhubung ke server. Periksa koneksi internet atau IP server backend.',
    super.statusCode,
    super.rawData,
  });
}
