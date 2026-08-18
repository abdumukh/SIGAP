import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/data/repositories/penugasan_repository.dart';
import 'package:sigap_mobile/data/services/penugasan_service.dart';

class MockPenugasanService extends Mock implements PenugasanService {}

void main() {
  late MockPenugasanService mockService;
  late PenugasanRepository repository;

  setUp(() {
    mockService = MockPenugasanService();
    repository = PenugasanRepository(service: mockService);
  });

  group('PenugasanRepository Tests', () {
    final samplePenugasanMap = {
      'id_penugasan': 'TGS-001',
      'id_alarm': 'ALM-001',
      'id_tim': 'TIM-001',
      'id_ketua_tim': 'PTG-001',
      'status_penugasan': 'menunggu',
    };

    test('getPenugasanList returns parsed list', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/penugasan'),
        data: {
          'status': 'success',
          'data': [samplePenugasanMap],
        },
      );

      when(() => mockService.getPenugasanList())
          .thenAnswer((_) async => response);

      final list = await repository.getPenugasanList();

      expect(list.length, 1);
      expect(list.first.idPenugasan, 'TGS-001');
    });

    test('getPenugasanById returns single PenugasanModel', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/penugasan/TGS-001'),
        data: {
          'status': 'success',
          'data': samplePenugasanMap,
        },
      );

      when(() => mockService.getPenugasanById('TGS-001'))
          .thenAnswer((_) async => response);

      final penugasan = await repository.getPenugasanById('TGS-001');

      expect(penugasan.idPenugasan, 'TGS-001');
      expect(penugasan.statusPenugasan, 'menunggu');
    });

    test('createPenugasan posts assignment payload and returns created model',
        () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/penugasan'),
        data: {
          'status': 'success',
          'data': samplePenugasanMap,
        },
      );

      when(() => mockService.createPenugasan(any()))
          .thenAnswer((_) async => response);

      final created = await repository.createPenugasan(
        idAlarm: 'ALM-001',
        idTim: 'TIM-001',
        idKetuaTim: 'PTG-001',
      );

      expect(created.idPenugasan, 'TGS-001');
      verify(() => mockService.createPenugasan(any())).called(1);
    });
  });
}
