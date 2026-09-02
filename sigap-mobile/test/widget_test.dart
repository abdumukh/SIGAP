import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/data/repositories/alarm_repository.dart';
import 'package:sigap_mobile/data/repositories/anggota_tim_repository.dart';
import 'package:sigap_mobile/data/repositories/auth_repository.dart';
import 'package:sigap_mobile/data/repositories/dokumentasi_repository.dart';
import 'package:sigap_mobile/data/repositories/korban_repository.dart';
import 'package:sigap_mobile/data/repositories/laporan_repository.dart';
import 'package:sigap_mobile/data/repositories/logistik_repository.dart';
import 'package:sigap_mobile/data/repositories/monitoring_repository.dart';
import 'package:sigap_mobile/data/repositories/notifikasi_repository.dart';
import 'package:sigap_mobile/data/repositories/penanganan_repository.dart';
import 'package:sigap_mobile/data/repositories/penugasan_repository.dart';
import 'package:sigap_mobile/data/repositories/tim_repository.dart';
import 'package:sigap_mobile/features/alarm/presentation/alarm_controller.dart';
import 'package:sigap_mobile/features/auth/presentation/auth_controller.dart';
import 'package:sigap_mobile/features/laporan/presentation/laporan_controller.dart';
import 'package:sigap_mobile/features/monitoring/presentation/monitoring_controller.dart';
import 'package:sigap_mobile/features/notifikasi/presentation/notifikasi_controller.dart';
import 'package:sigap_mobile/features/penanganan/presentation/dokumentasi_controller.dart';
import 'package:sigap_mobile/features/penanganan/presentation/korban_controller.dart';
import 'package:sigap_mobile/features/penanganan/presentation/logistik_controller.dart';
import 'package:sigap_mobile/features/penanganan/presentation/penanganan_controller.dart';
import 'package:sigap_mobile/features/penugasan/presentation/penugasan_controller.dart';
import 'package:sigap_mobile/features/tim/presentation/anggota_tim_controller.dart';
import 'package:sigap_mobile/features/tim/presentation/tim_controller.dart';
import 'package:sigap_mobile/main.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockAlarmRepository extends Mock implements AlarmRepository {}
class MockTimRepository extends Mock implements TimRepository {}
class MockAnggotaTimRepository extends Mock implements AnggotaTimRepository {}
class MockPenugasanRepository extends Mock implements PenugasanRepository {}
class MockPenangananRepository extends Mock implements PenangananRepository {}
class MockDokumentasiRepository extends Mock implements DokumentasiRepository {}
class MockNotifikasiRepository extends Mock implements NotifikasiRepository {}
class MockKorbanRepository extends Mock implements KorbanRepository {}
class MockLogistikRepository extends Mock implements LogistikRepository {}

class MockMonitoringRepository extends Mock implements MonitoringRepository {}
class MockLaporanRepository extends Mock implements LaporanRepository {}

void main() {
  testWidgets('SigapApp renders SplashScreen on startup and navigates to login when unauthenticated', (WidgetTester tester) async {
    final mockAuthRepo = MockAuthRepository();
    final mockAlarmRepo = MockAlarmRepository();
    final mockTimRepo = MockTimRepository();
    final mockAnggotaRepo = MockAnggotaTimRepository();
    final mockPenugasanRepo = MockPenugasanRepository();
    final mockPenangananRepo = MockPenangananRepository();
    final mockDokumentasiRepo = MockDokumentasiRepository();
    final mockNotifikasiRepo = MockNotifikasiRepository();
    final mockKorbanRepo = MockKorbanRepository();
    final mockLogistikRepo = MockLogistikRepository();
    final mockMonitoringRepo = MockMonitoringRepository();
    final mockLaporanRepo = MockLaporanRepository();

    when(() => mockAuthRepo.getCurrentUser()).thenAnswer((_) async => null);

    final authController = AuthController(repository: mockAuthRepo);
    final alarmController = AlarmController(repository: mockAlarmRepo);
    final timController = TimController(repository: mockTimRepo);
    final anggotaTimController =
        AnggotaTimController(repository: mockAnggotaRepo);
    final penugasanController =
        PenugasanController(repository: mockPenugasanRepo);
    final penangananController =
        PenangananController(repository: mockPenangananRepo);
    final dokumentasiController =
        DokumentasiController(repository: mockDokumentasiRepo);
    final notifikasiController =
        NotifikasiController(repository: mockNotifikasiRepo);
    final korbanController =
        KorbanController(repository: mockKorbanRepo);
    final logistikController =
        LogistikController(repository: mockLogistikRepo);
    final monitoringController = MonitoringController(
      repository: mockMonitoringRepo,
    );
    final laporanController = LaporanController(
      repository: mockLaporanRepo,
    );

    await tester.pumpWidget(SigapApp(
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

    // Initially on SplashScreen
    expect(find.text('SIGAP'), findsOneWidget);

    // Advance timer past the 800ms splash delay
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    // After splash, navigates to LoginScreen
    expect(find.text('Masuk ke Akun Anda'), findsOneWidget);
  });
}
