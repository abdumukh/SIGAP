import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/core/network/api_exceptions.dart';
import 'package:sigap_mobile/data/models/monitoring_model.dart';
import 'package:sigap_mobile/data/repositories/monitoring_repository.dart';
import 'package:sigap_mobile/features/monitoring/presentation/monitoring_controller.dart';

class MockMonitoringRepository extends Mock implements MonitoringRepository {}

void main() {
  late MockMonitoringRepository mockRepository;
  late MonitoringController controller;

  setUp(() {
    mockRepository = MockMonitoringRepository();
    controller = MonitoringController(repository: mockRepository);
  });

  group('MonitoringController', () {
    test('initial state is correct', () {
      expect(controller.status, MonitoringStateStatus.initial);
      expect(controller.data, isNull);
      expect(controller.errorMessage, isNull);
      expect(controller.isLoading, false);
      expect(controller.isEmpty, true);
    });

    test('fetchMonitoring sets loaded on success', () async {
      const mockModel = MonitoringModel(
        statistik: MonitoringStatistik(
          totalAlarm: 3,
          alarmByStatus: {},
          alarmByJenis: {},
          penugasanAktif: 1,
          penangananAktif: 0,
          penangananSelesai: 2,
          totalKorban: 0,
          totalLogistik: 0,
        ),
        activeOperations: [],
      );

      when(() => mockRepository.getMonitoring(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            status: any(named: 'status'),
            jenisDarurat: any(named: 'jenisDarurat'),
            idTim: any(named: 'idTim'),
          )).thenAnswer((_) async => mockModel);

      await controller.fetchMonitoring();

      expect(controller.status, MonitoringStateStatus.loaded);
      expect(controller.data, isNotNull);
      expect(controller.data!.statistik.totalAlarm, 3);
      expect(controller.hasError, false);
    });

    test('fetchMonitoring sets error on ApiException', () async {
      when(() => mockRepository.getMonitoring(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            status: any(named: 'status'),
            jenisDarurat: any(named: 'jenisDarurat'),
            idTim: any(named: 'idTim'),
          )).thenThrow(ForbiddenException(message: 'Akses ditolak'));

      await controller.fetchMonitoring();

      expect(controller.status, MonitoringStateStatus.error);
      expect(controller.errorMessage, 'Akses ditolak');
      expect(controller.hasError, true);
    });

    test('setFilter updates filter and refetches', () async {
      when(() => mockRepository.getMonitoring(
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

      controller.setFilter(
        startDate: '2026-01-01',
        status: 'diverifikasi',
      );

      expect(controller.startDate, '2026-01-01');
      expect(controller.statusFilter, 'diverifikasi');
      expect(controller.hasActiveFilter, true);
    });

    test('clearFilters resets filter state', () async {
      when(() => mockRepository.getMonitoring(
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

      controller.clearFilters();

      expect(controller.startDate, isNull);
      expect(controller.statusFilter, isNull);
      expect(controller.hasActiveFilter, false);
    });

    test('reset clears all controller state', () {
      controller.reset();

      expect(controller.status, MonitoringStateStatus.initial);
      expect(controller.data, isNull);
      expect(controller.errorMessage, isNull);
    });
  });
}