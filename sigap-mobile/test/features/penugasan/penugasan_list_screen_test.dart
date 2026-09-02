import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/data/models/penugasan_model.dart';
import 'package:sigap_mobile/data/repositories/alarm_repository.dart';
import 'package:sigap_mobile/data/repositories/auth_repository.dart';
import 'package:sigap_mobile/data/repositories/penugasan_repository.dart';
import 'package:sigap_mobile/data/repositories/tim_repository.dart';
import 'package:sigap_mobile/features/alarm/presentation/alarm_controller.dart';
import 'package:sigap_mobile/features/auth/presentation/auth_controller.dart';
import 'package:sigap_mobile/features/penugasan/presentation/penugasan_controller.dart';
import 'package:sigap_mobile/features/penugasan/presentation/penugasan_list_screen.dart';
import 'package:sigap_mobile/features/tim/presentation/tim_controller.dart';

class MockPenugasanRepository extends Mock implements PenugasanRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAlarmRepository extends Mock implements AlarmRepository {}

class MockTimRepository extends Mock implements TimRepository {}

void main() {
  late MockPenugasanRepository mockPenugasanRepo;
  late MockAuthRepository mockAuthRepo;
  late MockAlarmRepository mockAlarmRepo;
  late MockTimRepository mockTimRepo;

  late PenugasanController penugasanController;
  late AuthController authController;
  late AlarmController alarmController;
  late TimController timController;

  setUp(() {
    mockPenugasanRepo = MockPenugasanRepository();
    mockAuthRepo = MockAuthRepository();
    mockAlarmRepo = MockAlarmRepository();
    mockTimRepo = MockTimRepository();

    penugasanController =
        PenugasanController(repository: mockPenugasanRepo);
    authController = AuthController(repository: mockAuthRepo);
    alarmController = AlarmController(repository: mockAlarmRepo);
    timController = TimController(repository: mockTimRepo);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: PenugasanListScreen(
        penugasanController: penugasanController,
        authController: authController,
        alarmController: alarmController,
        timController: timController,
      ),
    );
  }

  testWidgets('PenugasanListScreen renders filter chips and empty state when no assignments',
      (tester) async {
    when(() => mockPenugasanRepo.getPenugasanList())
        .thenAnswer((_) async => []);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Daftar Penugasan Tim'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Menunggu'), findsOneWidget);
    expect(find.text('Diterima'), findsOneWidget);
    expect(find.text('Selesai'), findsOneWidget);
    expect(find.text('Belum Ada Data Penugasan'), findsOneWidget);
  });

  testWidgets('PenugasanListScreen displays assignments list correctly',
      (tester) async {
    const testList = [
      PenugasanModel(
        idPenugasan: 'TGS-001',
        idAlarm: 'ALM-001',
        idTim: 'TIM-001',
        idKetuaTim: 'PTG-001',
        statusPenugasan: 'menunggu',
        alarmJenisDarurat: 'Kebakaran',
        timNama: 'Tim Reaksi Cepat 1',
        ketuaTimNama: 'Ahmad Ketua',
      ),
    ];

    when(() => mockPenugasanRepo.getPenugasanList())
        .thenAnswer((_) async => testList);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('TGS-001'), findsOneWidget);
    expect(find.text('Kebakaran (ALM-001)'), findsOneWidget);
    expect(find.text('Tim: Tim Reaksi Cepat 1'), findsOneWidget);
    expect(find.text('Ketua: Ahmad Ketua'), findsOneWidget);
  });
}
