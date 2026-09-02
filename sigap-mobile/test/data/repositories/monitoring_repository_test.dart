import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/data/repositories/monitoring_repository.dart';
import 'package:sigap_mobile/data/services/monitoring_service.dart';

class MockMonitoringService extends Mock implements MonitoringService {}

void main() {
  late MockMonitoringService mockService;
  late MonitoringRepository repository;

  setUp(() {
    mockService = MockMonitoringService();
    repository = MonitoringRepository(service: mockService);
  });

  group('MonitoringRepository', () {
    test('getMonitoring returns MonitoringModel on success', () async {
      final jsonResponse = {
        'status': 'success',
        'message': 'OK',
        'data': {
          'statistik': {
            'total_alarm': 5,
            'alarm_by_status': {'diverifikasi': 5},
            'alarm_by_jenis': {'Banjir': 5},
            'penugasan_aktif': 1,
            'penanganan_aktif': 1,
            'penanganan_selesai': 0,
            'total_korban': 0,
            'total_logistik': 0,
          },
          'active_operations': [
            {
              'id_alarm': 'ALM-001',
              'jenis_darurat': 'Banjir',
              'latitude': -6.2,
              'longitude': 106.8,
              'status_alarm': 'diverifikasi',
            },
          ],
        },
      };

      when(() => mockService.getMonitoring(queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: jsonResponse,
                statusCode: 200,
                requestOptions: RequestOptions(path: '/monitoring'),
              ));

      final result = await repository.getMonitoring();

      expect(result.statistik.totalAlarm, 5);
      expect(result.activeOperations.length, 1);
      expect(result.activeOperations.first.idAlarm, 'ALM-001');
    });

    test('getMonitoring passes filters to queryParameters', () async {
      when(() => mockService.getMonitoring(queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: {
                  'data': {
                    'statistik': {'total_alarm': 0},
                    'active_operations': [],
                  },
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: '/monitoring'),
              ));

      await repository.getMonitoring(
        startDate: '2026-01-01',
        endDate: '2026-12-31',
        status: 'diverifikasi',
        jenisDarurat: 'Banjir',
        idTim: 'TIM-001',
      );

      verify(() => mockService.getMonitoring(
            queryParameters: {
              'start_date': '2026-01-01',
              'end_date': '2026-12-31',
              'status': 'diverifikasi',
              'jenis_darurat': 'Banjir',
              'id_tim': 'TIM-001',
            },
          )).called(1);
    });

    test('getMonitoring throws Exception when rawData is invalid', () async {
      when(() => mockService.getMonitoring(queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: 'invalid_data',
                statusCode: 200,
                requestOptions: RequestOptions(path: '/monitoring'),
              ));

      expect(() => repository.getMonitoring(), throwsA(isA<Exception>()));
    });
  });
}