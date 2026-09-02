import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/data/models/monitoring_model.dart';
import 'package:sigap_mobile/data/repositories/monitoring_repository.dart';
import 'package:sigap_mobile/features/monitoring/presentation/monitoring_controller.dart';
import 'package:sigap_mobile/features/monitoring/presentation/monitoring_screen.dart';

class MockMonitoringRepository extends Mock implements MonitoringRepository {}

void main() {
  testWidgets('MonitoringScreen shows loading indicator on initial state', (tester) async {
    final mockRepo = MockMonitoringRepository();

    when(() => mockRepo.getMonitoring(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          status: any(named: 'status'),
          jenisDarurat: any(named: 'jenisDarurat'),
          idTim: any(named: 'idTim'),
        )).thenAnswer((_) async => const MonitoringModel(
          statistik: MonitoringStatistik(
            totalAlarm: 0,
            alarmByStatus: {},
            alarmByJenis: {},
            penugasanAktif: 0,
            penangananAktif: 0,
            penangananSelesai: 0,
            totalKorban: 0,
            totalLogistik: 0,
          ),
          activeOperations: [],
        ));

    final controller = MonitoringController(repository: mockRepo);

    await tester.pumpWidget(MaterialApp(
      home: MonitoringScreen(controller: controller),
    ));

    // Initial state shows loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Monitoring'), findsOneWidget);

    // Let async resolve
    await tester.pump();
  });

  testWidgets('MonitoringScreen shows stats when data loaded', (tester) async {
    final mockRepo = MockMonitoringRepository();

    const mockData = MonitoringModel(
      statistik: MonitoringStatistik(
        totalAlarm: 10,
        alarmByStatus: {'diverifikasi': 10},
        alarmByJenis: {'Banjir': 10},
        penugasanAktif: 3,
        penangananAktif: 2,
        penangananSelesai: 1,
        totalKorban: 5,
        totalLogistik: 20,
      ),
      activeOperations: [
        ActiveOperation(
          idAlarm: 'ALM-001',
          jenisDarurat: 'Banjir',
          latitude: -6.2,
          longitude: 106.8,
          statusAlarm: 'diverifikasi',
        ),
      ],
    );

    when(() => mockRepo.getMonitoring(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          status: any(named: 'status'),
          jenisDarurat: any(named: 'jenisDarurat'),
          idTim: any(named: 'idTim'),
        )).thenAnswer((_) async => mockData);

    final controller = MonitoringController(repository: mockRepo);

    await tester.pumpWidget(MaterialApp(
      home: MonitoringScreen(controller: controller),
    ));

    await tester.pump();
    await tester.pump();

    expect(find.text('Total Alarm'), findsOneWidget);
    expect(find.text('Penugasan Aktif'), findsOneWidget);
    expect(find.text('Penanganan Aktif'), findsOneWidget);
    expect(find.text('Penanganan Selesai'), findsOneWidget);
  });

  testWidgets('MonitoringScreen shows empty state when no data', (tester) async {
    final mockRepo = MockMonitoringRepository();

    when(() => mockRepo.getMonitoring(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          status: any(named: 'status'),
          jenisDarurat: any(named: 'jenisDarurat'),
          idTim: any(named: 'idTim'),
        )).thenAnswer((_) async => const MonitoringModel(
          statistik: MonitoringStatistik(
            totalAlarm: 0,
            alarmByStatus: {},
            alarmByJenis: {},
            penugasanAktif: 0,
            penangananAktif: 0,
            penangananSelesai: 0,
            totalKorban: 0,
            totalLogistik: 0,
          ),
          activeOperations: [],
        ));

    final controller = MonitoringController(repository: mockRepo);

    await tester.pumpWidget(MaterialApp(
      home: MonitoringScreen(controller: controller),
    ));

    await tester.pump();
    await tester.pump();

    expect(find.text('Belum ada data monitoring'), findsOneWidget);
  });
}