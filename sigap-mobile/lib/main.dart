import 'package:flutter/material.dart';
import 'core/constants/app_theme.dart';
import 'core/network/api_client.dart';
import 'core/storage/auth_storage.dart';
import 'data/repositories/alarm_repository.dart';
import 'data/repositories/anggota_tim_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/dokumentasi_repository.dart';
import 'data/repositories/laporan_repository.dart';
import 'data/repositories/monitoring_repository.dart';
import 'data/repositories/notifikasi_repository.dart';
import 'data/repositories/penanganan_repository.dart';
import 'data/repositories/penugasan_repository.dart';
import 'data/repositories/tim_repository.dart';
import 'data/services/alarm_service.dart';
import 'data/services/anggota_tim_service.dart';
import 'data/services/auth_service.dart';
import 'data/services/dokumentasi_service.dart';
import 'data/services/laporan_service.dart';
import 'data/services/monitoring_service.dart';
import 'data/services/notifikasi_service.dart';
import 'data/services/penanganan_service.dart';
import 'data/services/penugasan_service.dart';
import 'data/services/tim_service.dart';
import 'features/alarm/presentation/alarm_controller.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/laporan/presentation/laporan_controller.dart';
import 'features/monitoring/presentation/monitoring_controller.dart';
import 'features/notifikasi/presentation/notifikasi_controller.dart';
import 'features/penanganan/presentation/dokumentasi_controller.dart';
import 'features/penanganan/presentation/penanganan_controller.dart';
import 'features/penugasan/presentation/penugasan_controller.dart';
import 'features/tim/presentation/anggota_tim_controller.dart';
import 'features/tim/presentation/tim_controller.dart';
import 'routes/app_routes.dart';

import 'data/repositories/korban_repository.dart';
import 'data/repositories/logistik_repository.dart';
import 'data/services/korban_service.dart';
import 'data/services/logistik_service.dart';
import 'features/penanganan/presentation/korban_controller.dart';
import 'features/penanganan/presentation/logistik_controller.dart';

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

  // Initialize Penanganan Services & Repository
  final penangananService = PenangananService(client: apiClient);
  final penangananRepository =
      PenangananRepository(service: penangananService);
  final penangananController =
      PenangananController(repository: penangananRepository);

  // Initialize Dokumentasi Services & Repository
  final dokumentasiService = DokumentasiService(client: apiClient);
  final dokumentasiRepository =
      DokumentasiRepository(service: dokumentasiService);
  final dokumentasiController =
      DokumentasiController(repository: dokumentasiRepository);

  // Initialize Notifikasi Services & Repository
  final notifikasiService = NotifikasiService(client: apiClient);
  final notifikasiRepository = NotifikasiRepository(service: notifikasiService);
  final notifikasiController = NotifikasiController(repository: notifikasiRepository);

  // Initialize Korban Services & Repository
  final korbanService = KorbanService(client: apiClient);
  final korbanRepository = KorbanRepository(service: korbanService);
  final korbanController = KorbanController(repository: korbanRepository);

  // Initialize Logistik Services & Repository
  final logistikService = LogistikService(client: apiClient);
  final logistikRepository = LogistikRepository(service: logistikService);
  final logistikController = LogistikController(repository: logistikRepository);

  // Initialize Monitoring Services & Repository (Fase 6A)
  final monitoringService = MonitoringService(client: apiClient);
  final monitoringRepository = MonitoringRepository(service: monitoringService);
  final monitoringController = MonitoringController(repository: monitoringRepository);

  // Initialize Laporan Services & Repository (Fase 6A)
  final laporanService = LaporanService(client: apiClient);
  final laporanRepository = LaporanRepository(service: laporanService);
  final laporanController = LaporanController(repository: laporanRepository);

  runApp(SigapApp(
    authController: authController,
    alarmController: alarmController,
    timController: timController,
    anggotaTimController: anggotaTimController,
    penugasanController: penugasanController,
    penangananController: penangananController,
    dokumentasiController: dokumentasiController,
    korbanController: korbanController,
    logistikController: logistikController,
    notifikasiController: notifikasiController,
    monitoringController: monitoringController,
    laporanController: laporanController,
  ));
}

class SigapApp extends StatelessWidget {
  final AuthController authController;
  final AlarmController alarmController;
  final TimController timController;
  final AnggotaTimController anggotaTimController;
  final PenugasanController penugasanController;
  final PenangananController penangananController;
  final DokumentasiController dokumentasiController;
  final KorbanController korbanController;
  final LogistikController logistikController;
  final NotifikasiController notifikasiController;
  final MonitoringController monitoringController;
  final LaporanController laporanController;

  const SigapApp({
    super.key,
    required this.authController,
    required this.alarmController,
    required this.timController,
    required this.anggotaTimController,
    required this.penugasanController,
    required this.penangananController,
    required this.dokumentasiController,
    required this.korbanController,
    required this.logistikController,
    required this.notifikasiController,
    required this.monitoringController,
    required this.laporanController,
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
        penangananController: penangananController,
        dokumentasiController: dokumentasiController,
        korbanController: korbanController,
        logistikController: logistikController,
        notifikasiController: notifikasiController,
        monitoringController: monitoringController,
        laporanController: laporanController,
      ),
    );
  }
}
