import 'package:flutter/material.dart';
import 'core/constants/app_theme.dart';
import 'core/network/api_client.dart';
import 'core/storage/auth_storage.dart';
import 'data/repositories/alarm_repository.dart';
import 'data/repositories/anggota_tim_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/penugasan_repository.dart';
import 'data/repositories/tim_repository.dart';
import 'data/services/alarm_service.dart';
import 'data/services/anggota_tim_service.dart';
import 'data/services/auth_service.dart';
import 'data/services/penugasan_service.dart';
import 'data/services/tim_service.dart';
import 'features/alarm/presentation/alarm_controller.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/penugasan/presentation/penugasan_controller.dart';
import 'features/tim/presentation/anggota_tim_controller.dart';
import 'features/tim/presentation/tim_controller.dart';
import 'routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Core Storage & Network Client
  final authStorage = AuthStorage();
  final apiClient = ApiClient(authStorage: authStorage);

  // Initialize Auth Services & Repository
  final authService = AuthService(client: apiClient);
  final authRepository = AuthRepository(
    service: authService,
    storage: authStorage,
  );
  final authController = AuthController(repository: authRepository);

  // Initialize Alarm Services & Repository
  final alarmService = AlarmService(client: apiClient);
  final alarmRepository = AlarmRepository(service: alarmService);
  final alarmController = AlarmController(repository: alarmRepository);

  // Initialize Tim & Anggota Services & Repositories
  final timService = TimService(client: apiClient);
  final timRepository = TimRepository(service: timService);
  final timController = TimController(repository: timRepository);

  final anggotaTimService = AnggotaTimService(client: apiClient);
  final anggotaTimRepository =
      AnggotaTimRepository(service: anggotaTimService);
  final anggotaTimController =
      AnggotaTimController(repository: anggotaTimRepository);

  // Initialize Penugasan Services & Repository
  final penugasanService = PenugasanService(client: apiClient);
  final penugasanRepository =
      PenugasanRepository(service: penugasanService);
  final penugasanController =
      PenugasanController(repository: penugasanRepository);

  runApp(SigapApp(
    authController: authController,
    alarmController: alarmController,
    timController: timController,
    anggotaTimController: anggotaTimController,
    penugasanController: penugasanController,
  ));
}

class SigapApp extends StatelessWidget {
  final AuthController authController;
  final AlarmController alarmController;
  final TimController timController;
  final AnggotaTimController anggotaTimController;
  final PenugasanController penugasanController;

  const SigapApp({
    super.key,
    required this.authController,
    required this.alarmController,
    required this.timController,
    required this.anggotaTimController,
    required this.penugasanController,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIGAP Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.getRoutes(
        authController: authController,
        alarmController: alarmController,
        timController: timController,
        anggotaTimController: anggotaTimController,
        penugasanController: penugasanController,
      ),
    );
  }
}
