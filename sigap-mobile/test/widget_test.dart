import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/data/repositories/alarm_repository.dart';
import 'package:sigap_mobile/data/repositories/anggota_tim_repository.dart';
import 'package:sigap_mobile/data/repositories/auth_repository.dart';
import 'package:sigap_mobile/data/repositories/penugasan_repository.dart';
import 'package:sigap_mobile/data/repositories/tim_repository.dart';
import 'package:sigap_mobile/features/alarm/presentation/alarm_controller.dart';
import 'package:sigap_mobile/features/auth/presentation/auth_controller.dart';
import 'package:sigap_mobile/features/penugasan/presentation/penugasan_controller.dart';
import 'package:sigap_mobile/features/tim/presentation/anggota_tim_controller.dart';
import 'package:sigap_mobile/features/tim/presentation/tim_controller.dart';
import 'package:sigap_mobile/main.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockAlarmRepository extends Mock implements AlarmRepository {}
class MockTimRepository extends Mock implements TimRepository {}
class MockAnggotaTimRepository extends Mock implements AnggotaTimRepository {}
class MockPenugasanRepository extends Mock implements PenugasanRepository {}

void main() {
  testWidgets('SigapApp renders SplashScreen on startup and navigates to login when unauthenticated', (WidgetTester tester) async {
    final mockAuthRepo = MockAuthRepository();
    final mockAlarmRepo = MockAlarmRepository();
    final mockTimRepo = MockTimRepository();
    final mockAnggotaRepo = MockAnggotaTimRepository();
    final mockPenugasanRepo = MockPenugasanRepository();

    when(() => mockAuthRepo.getCurrentUser()).thenAnswer((_) async => null);

    final authController = AuthController(repository: mockAuthRepo);
    final alarmController = AlarmController(repository: mockAlarmRepo);
    final timController = TimController(repository: mockTimRepo);
    final anggotaTimController =
        AnggotaTimController(repository: mockAnggotaRepo);
    final penugasanController =
        PenugasanController(repository: mockPenugasanRepo);

    await tester.pumpWidget(SigapApp(
      authController: authController,
      alarmController: alarmController,
      timController: timController,
      anggotaTimController: anggotaTimController,
      penugasanController: penugasanController,
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
