import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/data/repositories/penanganan_repository.dart';
import 'package:sigap_mobile/data/services/penanganan_service.dart';

class MockPenangananService extends Mock implements PenangananService {}

void main() {
  late MockPenangananService mockService;
  late PenangananRepository repository;

  setUp(() {
    mockService = MockPenangananService();
    repository = PenangananRepository(service: mockService);
  });

  group('PenangananRepository Tests', () {
    final samplePenangananMap = {
      'id_penanganan': 'PNG-001',
      'id_alarm': 'ALM-001',
      'id_penugasan': 'TGS-001',
      'id_petugas': 'PTG-001',
      'waktu_berangkat': '2026-08-20T10:00:00Z',
      'status_penanganan': 'menuju_lokasi',
      'note': 'Siap meluncur',
    };

    test('getPenangananList returns parsed list', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/penanganan'),
        data: {
          'status': 'success',
          'data': [samplePenangananMap],
        },
      );

      when(() => mockService.getPenangananList())
          .thenAnswer((_) async => response);

      final list = await repository.getPenangananList();

      expect(list.length, 1);
      expect(list.first.idPenanganan, 'PNG-001');
      expect(list.first.statusPenanganan, 'menuju_lokasi');
    });

    test('getPenangananById returns single model', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/penanganan/PNG-001'),
        data: {
          'status': 'success',
          'data': samplePenangananMap,
        },
      );

      when(() => mockService.getPenangananById('PNG-001'))
          .thenAnswer((_) async => response);

      final penanganan = await repository.getPenangananById('PNG-001');

      expect(penanganan.idPenanganan, 'PNG-001');
      expect(penanganan.idPenugasan, 'TGS-001');
    });

    test('createPenanganan posts payload and returns created model', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/penanganan'),
        data: {
          'status': 'success',
          'data': samplePenangananMap,
        },
      );

      when(() => mockService.createPenanganan(any()))
          .thenAnswer((_) async => response);

      final created = await repository.createPenanganan(
        idPenugasan: 'TGS-001',
        note: 'Siap meluncur',
      );

      expect(created.idPenanganan, 'PNG-001');
      verify(() => mockService.createPenanganan({
            'id_penugasan': 'TGS-001',
            'note': 'Siap meluncur',
          })).called(1);
    });

    test('updatePenangananStatus patches status and returns updated model', () async {
      final updatedMap = Map<String, dynamic>.from(samplePenangananMap)
        ..['status_penanganan'] = 'di_lokasi'
        ..['waktu_tiba'] = '2026-08-20T10:15:00Z';

      final response = Response(
        requestOptions: RequestOptions(path: '/penanganan/PNG-001'),
        data: {
          'status': 'success',
          'data': updatedMap,
        },
      );

      when(() => mockService.updatePenanganan('PNG-001', any()))
          .thenAnswer((_) async => response);

      final updated = await repository.updatePenangananStatus(
        'PNG-001',
        statusPenanganan: 'di_lokasi',
        note: 'Tiba di TKP',
      );

      expect(updated.statusPenanganan, 'di_lokasi');
      expect(updated.isDiLokasi, isTrue);
      verify(() => mockService.updatePenanganan('PNG-001', {
            'status_penanganan': 'di_lokasi',
            'note': 'Tiba di TKP',
          })).called(1);
    });

    test('repository throws Exception on invalid response format', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/penanganan/PNG-999'),
        data: {
          'status': 'error',
          'data': null,
        },
      );

      when(() => mockService.getPenangananById('PNG-999'))
          .thenAnswer((_) async => response);

      expect(() => repository.getPenangananById('PNG-999'), throwsException);
    });
  });
}
