import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/core/network/api_exceptions.dart';
import 'package:sigap_mobile/data/models/alarm_model.dart';
import 'package:sigap_mobile/data/repositories/alarm_repository.dart';
import 'package:sigap_mobile/features/alarm/presentation/alarm_controller.dart';

class MockAlarmRepository extends Mock implements AlarmRepository {}

void main() {
  late MockAlarmRepository mockRepository;
  late AlarmController controller;

  setUp(() {
    mockRepository = MockAlarmRepository();
    controller = AlarmController(repository: mockRepository);
  });

  group('AlarmController Tests', () {
    const testAlarm = AlarmModel(
      idAlarm: 'ALM-001',
      idPengguna: 'USR-001',
      jenisDarurat: 'Kebakaran',
      latitude: -6.2088000,
      longitude: 106.8456000,
      statusAlarm: 'menunggu',
    );

    test('fetchAlarms sets loaded state on success', () async {
      when(() => mockRepository.getAlarms()).thenAnswer((_) async => [testAlarm]);

      expect(controller.status, AlarmStateStatus.initial);

      await controller.fetchAlarms();

      expect(controller.status, AlarmStateStatus.loaded);
      expect(controller.alarms.length, 1);
      expect(controller.alarms.first.idAlarm, 'ALM-001');
    });

    test('fetchAlarms sets error state on failure', () async {
      when(() => mockRepository.getAlarms()).thenThrow(
        const ServerException(message: 'Server error occurred'),
      );

      await controller.fetchAlarms();

      expect(controller.status, AlarmStateStatus.error);
      expect(controller.errorMessage, 'Server error occurred');
      expect(controller.alarms, isEmpty);
    });

    test('fetchAlarmDetail sets selectedAlarm on success', () async {
      when(() => mockRepository.getAlarmById('ALM-001')).thenAnswer((_) async => testAlarm);

      await controller.fetchAlarmDetail('ALM-001');

      expect(controller.status, AlarmStateStatus.loaded);
      expect(controller.selectedAlarm, isNotNull);
      expect(controller.selectedAlarm!.idAlarm, 'ALM-001');
    });

    test('createAlarm inserts new alarm and updates state', () async {
      when(() => mockRepository.createAlarm(
            jenisDarurat: any(named: 'jenisDarurat'),
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            cuaca: any(named: 'cuaca'),
            laluLintas: any(named: 'laluLintas'),
          )).thenAnswer((_) async => testAlarm);

      final result = await controller.createAlarm(
        jenisDarurat: 'Kebakaran',
        latitude: -6.2,
        longitude: 106.8,
      );

      expect(result, isNotNull);
      expect(result!.idAlarm, 'ALM-001');
      expect(controller.status, AlarmStateStatus.success);
      expect(controller.alarms.length, 1);
      expect(controller.successMessage, isNotNull);
    });

    test('verifyAlarm updates local alarm in list and selectedAlarm', () async {
      final verifiedAlarm = AlarmModel(
        idAlarm: 'ALM-001',
        idPengguna: 'USR-001',
        jenisDarurat: 'Kebakaran',
        latitude: -6.2,
        longitude: 106.8,
        statusAlarm: 'diverifikasi',
      );

      when(() => mockRepository.getAlarms()).thenAnswer((_) async => [testAlarm]);
      when(() => mockRepository.verifyAlarm('ALM-001')).thenAnswer((_) async => verifiedAlarm);

      await controller.fetchAlarms();
      final success = await controller.verifyAlarm('ALM-001');

      expect(success, isTrue);
      expect(controller.alarms.first.statusAlarm, 'diverifikasi');
      expect(controller.status, AlarmStateStatus.success);
    });

    test('filter Alarms by status works correctly', () async {
      final alarm1 = AlarmModel(
        idAlarm: 'ALM-001',
        idPengguna: 'USR-001',
        jenisDarurat: 'Kebakaran',
        latitude: -6.2,
        longitude: 106.8,
        statusAlarm: 'menunggu',
      );

      final alarm2 = AlarmModel(
        idAlarm: 'ALM-002',
        idPengguna: 'USR-002',
        jenisDarurat: 'Banjir',
        latitude: -6.2,
        longitude: 106.8,
        statusAlarm: 'diverifikasi',
      );

      when(() => mockRepository.getAlarms()).thenAnswer((_) async => [alarm1, alarm2]);

      await controller.fetchAlarms();
      expect(controller.filteredAlarms.length, 2);

      controller.setFilter('diverifikasi');
      expect(controller.filteredAlarms.length, 1);
      expect(controller.filteredAlarms.first.idAlarm, 'ALM-002');

      controller.setFilter(null);
      expect(controller.filteredAlarms.length, 2);
    });
  });
}
