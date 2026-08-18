import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/core/constants/app_theme.dart';
import 'package:sigap_mobile/data/models/alarm_model.dart';
import 'package:sigap_mobile/data/models/anggota_tim_model.dart';
import 'package:sigap_mobile/data/models/tim_model.dart';
import 'package:sigap_mobile/data/repositories/alarm_repository.dart';
import 'package:sigap_mobile/data/repositories/penugasan_repository.dart';
import 'package:sigap_mobile/data/repositories/tim_repository.dart';
import 'package:sigap_mobile/features/alarm/presentation/alarm_controller.dart';
import 'package:sigap_mobile/features/penugasan/presentation/create_penugasan_screen.dart';
import 'package:sigap_mobile/features/penugasan/presentation/penugasan_controller.dart';
import 'package:sigap_mobile/features/tim/presentation/tim_controller.dart';

class MockAlarmRepository extends Mock implements AlarmRepository {}
class MockTimRepository extends Mock implements TimRepository {}
class MockPenugasanRepository extends Mock implements PenugasanRepository {}

void main() {
  late MockAlarmRepository mockAlarmRepo;
  late MockTimRepository mockTimRepo;
  late MockPenugasanRepository mockPenugasanRepo;

  late AlarmController alarmController;
  late TimController timController;
  late PenugasanController penugasanController;

  const testAlarm = AlarmModel(
    idAlarm: 'ALM-001',
    idPengguna: 'USR-001',
    jenisDarurat: 'Kebakaran',
    latitude: -6.2088,
    longitude: 106.8456,
    statusAlarm: 'diverifikasi',
  );

  const testTim = TimModel(
    idTim: 'TIM-001',
    namaTim: 'Tim Reaksi Cepat 1',
    statusTim: 'aktif',
    anggotaTim: [
      AnggotaTimModel(
        idAnggotaTim: 'AGT-001',
        idTim: 'TIM-001',
        idPetugas: 'PTG-001',
        statusAnggota: 'aktif',
        namaPetugas: 'Ahmad Ketua',
        role: 'ketua_tim',
      ),
    ],
  );

  setUp(() {
    mockAlarmRepo = MockAlarmRepository();
    mockTimRepo = MockTimRepository();
    mockPenugasanRepo = MockPenugasanRepository();

    alarmController = AlarmController(repository: mockAlarmRepo);
    timController = TimController(repository: mockTimRepo);
    penugasanController =
        PenugasanController(repository: mockPenugasanRepo);

    when(() => mockAlarmRepo.getAlarms())
        .thenAnswer((_) async => [testAlarm]);
    when(() => mockTimRepo.getTimList())
        .thenAnswer((_) async => [testTim]);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: CreatePenugasanScreen(
        alarmController: alarmController,
        timController: timController,
        penugasanController: penugasanController,
      ),
    );
  }

  group('CreatePenugasanScreen Widget Tests', () {
    testWidgets('renders all essential assignment form sections',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Buat Penugasan Tim'), findsOneWidget);
      expect(find.text('1. Alarm Darurat *'), findsOneWidget);
      expect(find.text('2. Tim Operasional *'), findsOneWidget);
      expect(find.text('3. Ketua Tim Penanggung Jawab *'), findsOneWidget);
      expect(find.text('BUAT PENUGASAN SEKARANG'), findsOneWidget);
    });
  });
}
