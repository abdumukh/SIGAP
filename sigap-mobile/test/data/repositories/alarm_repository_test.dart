import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/data/repositories/alarm_repository.dart';
import 'package:sigap_mobile/data/services/alarm_service.dart';

class MockAlarmService extends Mock implements AlarmService {}

void main() {
  late MockAlarmService mockService;
  late AlarmRepository repository;

  setUp(() {
    mockService = MockAlarmService();
    repository = AlarmRepository(service: mockService);
  });

  group('AlarmRepository Tests', () {
    final sampleAlarmMap = {
      'id_alarm': 'ALM-001',
      'id_pengguna': 'USR-001',
      'jenis_darurat': 'Kebakaran',
      'latitude': -6.2088000,
      'longitude': 106.8456000,
      'status_alarm': 'menunggu',
    };

    test('getAlarms returns parsed list of AlarmModel', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/alarms'),
        data: {
          'status': 'success',
          'data': [sampleAlarmMap],
        },
      );

      when(() => mockService.getAlarms()).thenAnswer((_) async => response);

      final list = await repository.getAlarms();

      expect(list.length, 1);
      expect(list.first.idAlarm, 'ALM-001');
      expect(list.first.jenisDarurat, 'Kebakaran');
    });

    test('getAlarmById returns AlarmModel on success', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/alarms/ALM-001'),
        data: {
          'status': 'success',
          'data': sampleAlarmMap,
        },
      );

      when(() => mockService.getAlarmById('ALM-001')).thenAnswer((_) async => response);

      final alarm = await repository.getAlarmById('ALM-001');

      expect(alarm.idAlarm, 'ALM-001');
      expect(alarm.statusAlarm, 'menunggu');
    });

    test('createAlarm posts data and returns created AlarmModel', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/alarms'),
        data: {
          'status': 'success',
          'data': sampleAlarmMap,
        },
      );

      when(() => mockService.createAlarm(any())).thenAnswer((_) async => response);

      final alarm = await repository.createAlarm(
        jenisDarurat: 'Kebakaran',
        latitude: -6.2088000,
        longitude: 106.8456000,
      );

      expect(alarm.idAlarm, 'ALM-001');
      verify(() => mockService.createAlarm(any())).called(1);
    });

    test('verifyAlarm calls service and returns updated AlarmModel', () async {
      final verifiedMap = Map<String, dynamic>.from(sampleAlarmMap);
      verifiedMap['status_alarm'] = 'diverifikasi';

      final response = Response(
        requestOptions: RequestOptions(path: '/alarms/ALM-001/verify'),
        data: {
          'status': 'success',
          'data': verifiedMap,
        },
      );

      when(() => mockService.verifyAlarm('ALM-001')).thenAnswer((_) async => response);

      final alarm = await repository.verifyAlarm('ALM-001');

      expect(alarm.idAlarm, 'ALM-001');
      expect(alarm.statusAlarm, 'diverifikasi');
      verify(() => mockService.verifyAlarm('ALM-001')).called(1);
    });

    test('rejectAlarm calls service and returns updated AlarmModel', () async {
      final rejectedMap = Map<String, dynamic>.from(sampleAlarmMap);
      rejectedMap['status_alarm'] = 'ditolak';

      final response = Response(
        requestOptions: RequestOptions(path: '/alarms/ALM-001/reject'),
        data: {
          'status': 'success',
          'data': rejectedMap,
        },
      );

      when(() => mockService.rejectAlarm('ALM-001')).thenAnswer((_) async => response);

      final alarm = await repository.rejectAlarm('ALM-001');

      expect(alarm.statusAlarm, 'ditolak');
      verify(() => mockService.rejectAlarm('ALM-001')).called(1);
    });

    test('completeAlarm calls service and returns updated AlarmModel', () async {
      final completedMap = Map<String, dynamic>.from(sampleAlarmMap);
      completedMap['status_alarm'] = 'selesai';

      final response = Response(
        requestOptions: RequestOptions(path: '/alarms/ALM-001/complete'),
        data: {
          'status': 'success',
          'data': completedMap,
        },
      );

      when(() => mockService.completeAlarm('ALM-001')).thenAnswer((_) async => response);

      final alarm = await repository.completeAlarm('ALM-001');

      expect(alarm.statusAlarm, 'selesai');
      verify(() => mockService.completeAlarm('ALM-001')).called(1);
    });
  });
}
