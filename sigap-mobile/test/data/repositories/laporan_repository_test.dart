import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/data/models/laporan_model.dart';
import 'package:sigap_mobile/data/repositories/laporan_repository.dart';
import 'package:sigap_mobile/data/services/laporan_service.dart';

class MockLaporanService extends Mock implements LaporanService {}

void main() {
  late MockLaporanService mockService;
  late LaporanRepository repository;

  setUp(() {
    mockService = MockLaporanService();
    repository = LaporanRepository(service: mockService);
  });

  group('LaporanRepository', () {
    test('getLaporan returns LaporanModel on success', () async {
      final jsonResponse = {
        'status': 'success',
        'message': 'OK',
        'data': {
          'type': 'alarm',
          'total': 2,
          'items': [
            {'id_alarm': 'ALM-001', 'jenis_darurat': 'Banjir'},
            {'id_alarm': 'ALM-002', 'jenis_darurat': 'Kebakaran'},
          ],
        },
      };

      when(() => mockService.getLaporan(queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: jsonResponse,
                statusCode: 200,
                requestOptions: RequestOptions(path: '/laporan'),
              ));

      const filter = LaporanFilter(type: 'alarm');
      final result = await repository.getLaporan(filter: filter);

      expect(result.type, 'alarm');
      expect(result.total, 2);
      expect(result.items.length, 2);
    });

    test('getLaporan throws ArgumentError when type is missing', () async {
      const filter = LaporanFilter();
      expect(() => repository.getLaporan(filter: filter), throwsA(isA<ArgumentError>()));
    });

    test('getLaporan passes filter params correctly', () async {
      when(() => mockService.getLaporan(queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: {
                  'data': {'type': 'penugasan', 'total': 0, 'items': []},
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: '/laporan'),
              ));

      const filter = LaporanFilter(
        type: 'penugasan',
        startDate: '2026-01-01',
        endDate: '2026-12-31',
        status: 'selesai',
        idTim: 'TIM-001',
      );

      await repository.getLaporan(filter: filter);

      verify(() => mockService.getLaporan(
            queryParameters: {
              'type': 'penugasan',
              'start_date': '2026-01-01',
              'end_date': '2026-12-31',
              'status': 'selesai',
              'id_tim': 'TIM-001',
            },
          )).called(1);
    });

    test('getLaporan throws Exception on invalid rawData', () async {
      when(() => mockService.getLaporan(queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: 'invalid_string',
                statusCode: 200,
                requestOptions: RequestOptions(path: '/laporan'),
              ));

      const filter = LaporanFilter(type: 'alarm');
      expect(() => repository.getLaporan(filter: filter), throwsA(isA<Exception>()));
    });
  });
}