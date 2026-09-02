import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/core/network/api_exceptions.dart';
import 'package:sigap_mobile/data/models/dokumentasi_model.dart';
import 'package:sigap_mobile/data/repositories/dokumentasi_repository.dart';
import 'package:sigap_mobile/features/penanganan/presentation/dokumentasi_controller.dart';

class MockDokumentasiRepository extends Mock implements DokumentasiRepository {}

void main() {
  late MockDokumentasiRepository mockRepository;
  late DokumentasiController controller;

  setUp(() {
    mockRepository = MockDokumentasiRepository();
    controller = DokumentasiController(repository: mockRepository);
  });

  group('DokumentasiController Tests', () {
    const sampleDoc = DokumentasiModel(
      idDokumentasi: 'DOC-001',
      idPenanganan: 'PNG-001',
      idPetugas: 'PTG-001',
      jenisDokumentasi: 'foto',
      fileDokumentasi: 'dokumentasi/foto.jpg',
      waktuUpload: '2026-08-20T10:30:00Z',
    );

    test('fetchDokumentasiList sets loaded state on success', () async {
      when(() => mockRepository.getDokumentasiList())
          .thenAnswer((_) async => [sampleDoc]);

      await controller.fetchDokumentasiList();

      expect(controller.status, DokumentasiStateStatus.loaded);
      expect(controller.dokumentasiList.length, 1);
      expect(controller.errorMessage, isNull);
    });

    test('fetchDokumentasiList sets error state on ApiException', () async {
      when(() => mockRepository.getDokumentasiList()).thenThrow(
        const ApiException(message: 'Forbidden. Akses ditolak.'),
      );

      await controller.fetchDokumentasiList();

      expect(controller.status, DokumentasiStateStatus.error);
      expect(controller.errorMessage, 'Forbidden. Akses ditolak.');
    });

    test('uploadDokumentasi inserts uploaded doc and updates state', () async {
      when(() => mockRepository.createDokumentasi(
            idPenanganan: 'PNG-001',
            jenisDokumentasi: 'foto',
            fileDokumentasi: any(named: 'fileDokumentasi'),
            note: any(named: 'note'),
          )).thenAnswer((_) async => sampleDoc);

      final result = await controller.uploadDokumentasi(
        idPenanganan: 'PNG-001',
        jenisDokumentasi: 'foto',
        file: 'dokumentasi/foto.jpg',
        note: 'Foto dokumentasi',
      );

      expect(result, isNotNull);
      expect(result?.idDokumentasi, 'DOC-001');
      expect(controller.status, DokumentasiStateStatus.success);
      expect(controller.dokumentasiList.length, 1);
    });

    test('deleteDokumentasi removes item from local list on success', () async {
      when(() => mockRepository.getDokumentasiList())
          .thenAnswer((_) async => [sampleDoc]);
      await controller.fetchDokumentasiList();

      when(() => mockRepository.deleteDokumentasi('DOC-001'))
          .thenAnswer((_) async => true);

      final success = await controller.deleteDokumentasi('DOC-001');

      expect(success, isTrue);
      expect(controller.status, DokumentasiStateStatus.success);
      expect(controller.dokumentasiList.isEmpty, isTrue);
    });

    test('getDokumentasiForPenanganan filters by target penanganan id', () async {
      const doc2 = DokumentasiModel(
        idDokumentasi: 'DOC-002',
        idPenanganan: 'PNG-002',
        idPetugas: 'PTG-002',
        jenisDokumentasi: 'video',
        fileDokumentasi: 'dokumentasi/video.mp4',
      );

      when(() => mockRepository.getDokumentasiList())
          .thenAnswer((_) async => [sampleDoc, doc2]);
      await controller.fetchDokumentasiList();

      final filtered = controller.getDokumentasiForPenanganan('PNG-001');
      expect(filtered.length, 1);
      expect(filtered.first.idDokumentasi, 'DOC-001');
    });
  });
}
