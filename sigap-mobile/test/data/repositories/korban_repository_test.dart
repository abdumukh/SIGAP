import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/data/repositories/korban_repository.dart';
import 'package:sigap_mobile/data/services/korban_service.dart';

class MockKorbanService extends Mock implements KorbanService {}

void main() {
  late MockKorbanService mockService;
  late KorbanRepository repository;

  setUp(() {
    mockService = MockKorbanService();
    repository = KorbanRepository(service: mockService);
  });

  group('KorbanRepository Tests', () {
    final sampleKorbanMap = {
      'id_korban': 'KRB-001',
      'id_penanganan': 'PNG-001',
      'nama_korban': 'Budi Santoso',
      'jenis_kelamin': 'L',
      'usia': 35,
      'kondisi': 'Luka Ringan',
      'status_penanganan': 'Dievakuasi ke RS',
    };

    test('getKorbanList returns parsed list', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/korban'),
        data: {
          'status': 'success',
          'data': [sampleKorbanMap],
        },
      );

      when(() => mockService.getKorbanList())
          .thenAnswer((_) async => response);

      final list = await repository.getKorbanList();

      expect(list.length, 1);
      expect(list.first.idKorban, 'KRB-001');
      expect(list.first.namaKorban, 'Budi Santoso');
      expect(list.first.jenisKelamin, 'L');
    });

    test('getKorbanById returns single KorbanModel', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/korban/KRB-001'),
        data: {
          'status': 'success',
          'data': sampleKorbanMap,
        },
      );

      when(() => mockService.getKorbanById('KRB-001'))
          .thenAnswer((_) async => response);

      final korban = await repository.getKorbanById('KRB-001');

      expect(korban.idKorban, 'KRB-001');
      expect(korban.idPenanganan, 'PNG-001');
    });

    test('createKorban posts data and returns created model', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/korban'),
        data: {
          'status': 'success',
          'data': sampleKorbanMap,
        },
      );

      when(() => mockService.createKorban(any()))
          .thenAnswer((_) async => response);

      final created = await repository.createKorban(
        idPenanganan: 'PNG-001',
        namaKorban: 'Budi Santoso',
        jenisKelamin: 'L',
        usia: 35,
        kondisi: 'Luka Ringan',
        statusPenanganan: 'Dievakuasi ke RS',
        note: 'Perlu perawatan medis',
      );

      expect(created.idKorban, 'KRB-001');
      verify(() => mockService.createKorban(any())).called(1);
    });

    test('deleteKorban sends delete request and returns true on success', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/korban/KRB-001'),
        data: {
          'status': 'success',
          'message': 'Data korban berhasil dihapus',
        },
      );

      when(() => mockService.deleteKorban('KRB-001'))
          .thenAnswer((_) async => response);

      final success = await repository.deleteKorban('KRB-001');

      expect(success, isTrue);
      verify(() => mockService.deleteKorban('KRB-001')).called(1);
    });
  });
}