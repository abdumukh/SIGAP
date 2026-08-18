import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/core/constants/app_theme.dart';
import 'package:sigap_mobile/data/models/alarm_model.dart';
import 'package:sigap_mobile/data/repositories/alarm_repository.dart';
import 'package:sigap_mobile/features/alarm/presentation/alarm_controller.dart';
import 'package:sigap_mobile/features/alarm/presentation/create_alarm_screen.dart';

class MockAlarmRepository extends Mock implements AlarmRepository {}

void main() {
  late MockAlarmRepository mockAlarmRepo;
  late AlarmController alarmController;

  setUp(() {
    mockAlarmRepo = MockAlarmRepository();
    alarmController = AlarmController(repository: mockAlarmRepo);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: CreateAlarmScreen(
        alarmController: alarmController,
      ),
    );
  }

  group('CreateAlarmScreen Widget Tests', () {
    testWidgets('renders all emergency form fields and submit button', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Buat Laporan Darurat'), findsOneWidget);
      expect(find.text('Jenis Keadaan Darurat *'), findsOneWidget);
      expect(find.text('Kebakaran'), findsOneWidget);
      expect(find.text('Medis Darurat'), findsOneWidget);
      expect(find.text('KIRIM LAPORAN DARURAT'), findsOneWidget);
      expect(find.text('Latitude'), findsOneWidget);
      expect(find.text('Longitude'), findsOneWidget);
    });

    testWidgets('submitting form triggers createAlarm on controller', (tester) async {
      const testAlarm = AlarmModel(
        idAlarm: 'ALM-999',
        idPengguna: 'USR-001',
        jenisDarurat: 'Kebakaran',
        latitude: -6.2088,
        longitude: 106.8456,
        statusAlarm: 'menunggu',
      );

      when(() => mockAlarmRepo.createAlarm(
            jenisDarurat: any(named: 'jenisDarurat'),
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            cuaca: any(named: 'cuaca'),
            laluLintas: any(named: 'laluLintas'),
          )).thenAnswer((_) async => testAlarm);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final submitButton = find.text('KIRIM LAPORAN DARURAT');
      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();

      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      verify(() => mockAlarmRepo.createAlarm(
            jenisDarurat: 'Kebakaran',
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            cuaca: any(named: 'cuaca'),
            laluLintas: any(named: 'laluLintas'),
          )).called(1);
    });
  });
}
