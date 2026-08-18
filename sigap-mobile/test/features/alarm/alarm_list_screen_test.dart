import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/core/constants/app_theme.dart';
import 'package:sigap_mobile/data/models/alarm_model.dart';
import 'package:sigap_mobile/data/models/user_model.dart';
import 'package:sigap_mobile/data/repositories/alarm_repository.dart';
import 'package:sigap_mobile/data/repositories/auth_repository.dart';
import 'package:sigap_mobile/features/alarm/presentation/alarm_controller.dart';
import 'package:sigap_mobile/features/alarm/presentation/alarm_list_screen.dart';
import 'package:sigap_mobile/features/auth/presentation/auth_controller.dart';

class MockAlarmRepository extends Mock implements AlarmRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAlarmRepository mockAlarmRepo;
  late MockAuthRepository mockAuthRepo;
  late AlarmController alarmController;
  late AuthController authController;

  const testMasyarakat = UserModel(
    id: 'USR-001',
    name: 'Masyarakat Test',
    email: 'masyarakat@sigap.go.id',
    role: 'masyarakat',
  );

  const testAlarm = AlarmModel(
    idAlarm: 'ALM-001',
    idPengguna: 'USR-001',
    jenisDarurat: 'Kebakaran',
    latitude: -6.2088,
    longitude: 106.8456,
    statusAlarm: 'menunggu',
  );

  setUp(() {
    mockAlarmRepo = MockAlarmRepository();
    mockAuthRepo = MockAuthRepository();
    alarmController = AlarmController(repository: mockAlarmRepo);
    authController = AuthController(repository: mockAuthRepo);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: AlarmListScreen(
        alarmController: alarmController,
        authController: authController,
      ),
    );
  }

  group('AlarmListScreen Widget Tests', () {
    testWidgets('renders filter chips and empty state when no alarms', (tester) async {
      when(() => mockAlarmRepo.getAlarms()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Menunggu'), findsOneWidget);
      expect(find.text('Diverifikasi'), findsOneWidget);
      expect(find.text('Belum Ada Laporan Alarm'), findsOneWidget);
    });

    testWidgets('renders alarm cards when data exists', (tester) async {
      when(() => mockAlarmRepo.getAlarms()).thenAnswer((_) async => [testAlarm]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('ALM-001'), findsOneWidget);
      expect(find.text('Kebakaran'), findsOneWidget);
      expect(find.text('Menunggu'), findsWidgets);
    });

    testWidgets('shows Buat Laporan FAB for masyarakat user', (tester) async {
      when(() => mockAlarmRepo.getAlarms()).thenAnswer((_) async => []);
      when(() => mockAuthRepo.getCurrentUser()).thenAnswer((_) async => testMasyarakat);

      await authController.checkAuthStatus();

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Buat Laporan'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
