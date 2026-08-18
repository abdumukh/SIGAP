import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/data/repositories/tim_repository.dart';
import 'package:sigap_mobile/data/services/tim_service.dart';

class MockTimService extends Mock implements TimService {}

void main() {
  late MockTimService mockService;
  late TimRepository repository;

  setUp(() {
    mockService = MockTimService();
    repository = TimRepository(service: mockService);
  });

  group('TimRepository Tests', () {
    final sampleTimMap = {
      'id_tim': 'TIM-001',
      'nama_tim': 'Tim Reaksi Cepat 1',
      'note': 'Jakarta Pusat',
      'status_tim': 'aktif',
      'anggota_tim': [],
    };

    test('getTimList returns parsed list of TimModel', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/tim'),
        data: {
          'status': 'success',
          'data': [sampleTimMap],
        },
      );

      when(() => mockService.getTimList()).thenAnswer((_) async => response);

      final list = await repository.getTimList();

      expect(list.length, 1);
      expect(list.first.idTim, 'TIM-001');
      expect(list.first.namaTim, 'Tim Reaksi Cepat 1');
    });

    test('getTimById returns TimModel on success', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/tim/TIM-001'),
        data: {
          'status': 'success',
          'data': sampleTimMap,
        },
      );

      when(() => mockService.getTimById('TIM-001'))
          .thenAnswer((_) async => response);

      final tim = await repository.getTimById('TIM-001');

      expect(tim.idTim, 'TIM-001');
      expect(tim.statusTim, 'aktif');
    });

    test('createTim posts data and returns created TimModel', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/tim'),
        data: {
          'status': 'success',
          'data': sampleTimMap,
        },
      );

      when(() => mockService.createTim(any()))
          .thenAnswer((_) async => response);

      final created = await repository.createTim(
        namaTim: 'Tim Reaksi Cepat 1',
        note: 'Jakarta Pusat',
      );

      expect(created.idTim, 'TIM-001');
      verify(() => mockService.createTim(any())).called(1);
    });

    test('updateTim updates and returns updated TimModel', () async {
      final updatedMap = Map<String, dynamic>.from(sampleTimMap);
      updatedMap['nama_tim'] = 'Tim Alpha Baru';

      final response = Response(
        requestOptions: RequestOptions(path: '/tim/TIM-001'),
        data: {
          'status': 'success',
          'data': updatedMap,
        },
      );

      when(() => mockService.updateTim('TIM-001', any()))
          .thenAnswer((_) async => response);

      final updated = await repository.updateTim(
        'TIM-001',
        namaTim: 'Tim Alpha Baru',
      );

      expect(updated.namaTim, 'Tim Alpha Baru');
    });

    test('deleteTim deactivates team and returns updated TimModel', () async {
      final deactivatedMap = Map<String, dynamic>.from(sampleTimMap);
      deactivatedMap['status_tim'] = 'nonaktif';

      final response = Response(
        requestOptions: RequestOptions(path: '/tim/TIM-001'),
        data: {
          'status': 'success',
          'data': deactivatedMap,
        },
      );

      when(() => mockService.deleteTim('TIM-001'))
          .thenAnswer((_) async => response);

      final deleted = await repository.deleteTim('TIM-001');

      expect(deleted.isNonaktif, isTrue);
    });
  });
}
