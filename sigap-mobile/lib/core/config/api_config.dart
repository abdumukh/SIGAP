/// Configuration for SIGAP backend API endpoints.
/// Supports switching between LAN IP (physical Android device), Android Emulator, and Localhost.
class ApiConfig {
  ApiConfig._();

  /// Default LAN IP of development machine.
  /// Used for physical Android device testing over Wi-Fi.
  static const String defaultLanIp = '192.168.1.49';

  /// Default port where Laravel backend is running.
  static const int defaultPort = 8000;

  /// Android Emulator loopback alias.
  static const String emulatorBaseUrl = 'http://10.0.2.2:$defaultPort/api';

  /// Localhost (for desktop / web testing).
  static const String localhostBaseUrl = 'http://127.0.0.1:$defaultPort/api';

  /// Physical device LAN base URL.
  static const String lanBaseUrl = 'http://$defaultLanIp:$defaultPort/api';

  /// Current active Base URL.
  /// Defaults to [lanBaseUrl] for physical device testing as requested.
  static String baseUrl = lanBaseUrl;

  /// Timeout configurations.
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  /// Auth endpoints.
  static const String loginEndpoint = '/auth/login';
  static const String logoutEndpoint = '/auth/logout';
  static const String meEndpoint = '/auth/me';
  static const String registerEndpoint = '/auth/register';

  /// Helper to dynamically update the host IP for testing on different networks.
  static void setCustomIp(String ip, {int port = defaultPort}) {
    baseUrl = 'http://$ip:$port/api';
  }

  /// Helper to reset to default LAN IP.
  static void resetToDefault() {
    baseUrl = lanBaseUrl;
  }
}
