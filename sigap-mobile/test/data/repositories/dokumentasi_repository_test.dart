import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/data/repositories/dokumentasi_repository.dart';
import 'package:sigap_mobile/data/services/dokumentasi_service.dart';

class MockDokumentasiService extends Mock implements DokumentasiService {}

void main() {
  late MockDokumentasiService mockService;
  late DokumentasiRepository repository;

  setUp(() {
    mockService = MockDokumentasiService();
    repository = DokumentasiRepository(service: mockService);
  });

  group('DokumentasiRepository Tests', () {
    final sampleDocMap = {
      'id_dokumentasi': 'DOC-001',
      'id_penanganan': 'PNG-001',
      'id_petugas': 'PTG-001',
      'jenis_dokumentasi': 'foto',
      'file_dokumentasi': 'dokumentasi/foto.jpg',
      'waktu_upload': '2026-08-20T10:30:00Z',
    };

    test('getDokumentasiList returns parsed list', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/dokumentasi'),
        data: {
          'status': 'success',
          'data': [sampleDocMap],
        },
      );

      when(() => mockService.getDokumentasiList())
          .thenAnswer((_) async => response);

      final list = await repository.getDokumentasiList();

      expect(list.length, 1);
      expect(list.first.idDokumentasi, 'DOC-001');
      expect(list.first.jenisDokumentasi, 'foto');
    });

    test('getDokumentasiById returns single DokumentasiModel', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/dokumentasi/DOC-001'),
        data: {
          'status': 'success',
          'data': sampleDocMap,
        },
      );

      when(() => mockService.getDokumentasiById('DOC-001'))
          .thenAnswer((_) async => response);

      final doc = await repository.getDokumentasiById('DOC-001');

      expect(doc.idDokumentasi, 'DOC-001');
      expect(doc.idPenanganan, 'PNG-001');
    });

    test('createDokumentasi posts data and returns created model', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/dokumentasi'),
        data: {
          'status': 'success',
          'data': sampleDocMap,
        },
      );

      when(() => mockService.createDokumentasi(any()))
          .thenAnswer((_) async => response);

      final created = await repository.createDokumentasi(
        idPenanganan: 'PNG-001',
        jenisDokumentasi: 'foto',
        fileDokumentasi: 'dokumentasi/foto.jpg',
        note: 'Foto awal kejadian',
      );

      expect(created.idDokumentasi, 'DOC-001');
      verify(() => mockService.createDokumentasi(any())).called(1);
    });

    test('deleteDokumentasi sends delete request and returns true on success', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/dokumentasi/DOC-001'),
        data: {
          'status': 'success',
          'message': 'Dokumentasi berhasil dihapus',
        },
      );

      when(() => mockService.deleteDokumentasi('DOC-001'))
          .thenAnswer((_) async => response);

      final success = await repository.deleteDokumentasi('DOC-001');

      expect(success, isTrue);
      verify(() => mockService.deleteDokumentasi('DOC-001')).called(1);
    });
  });
}
