import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/core/network/api_exceptions.dart';
import 'package:sigap_mobile/data/models/logistik_model.dart';
import 'package:sigap_mobile/data/repositories/logistik_repository.dart';
import 'package:sigap_mobile/features/penanganan/presentation/logistik_controller.dart';

class MockLogistikRepository extends Mock implements LogistikRepository {}

void main() {
  late MockLogistikRepository mockRepository;
  late LogistikController controller;

  setUp(() {
    mockRepository = MockLogistikRepository();
    controller = LogistikController(repository: mockRepository);
  });

  group('LogistikController Tests', () {
    const sampleLogistik = LogistikModel(
      idLogistik: 'LOG-001',
      idPenanganan: 'PNG-001',
      namaLogistik: 'Selang Pemadam',
      jumlah: 4,
      satuan: 'Unit',
      kondisi: 'Baik',
    );

    test('initial state is correct', () {
      expect(controller.status, LogistikStateStatus.initial);
      expect(controller.logistikList, isEmpty);
      expect(controller.selectedLogistik, isNull);
      expect(controller.errorMessage, isNull);
      expect(controller.successMessage, isNull);
      expect(controller.isLoading, isFalse);
      expect(controller.isCreating, isFalse);
      expect(controller.isDeleting, isFalse);
    });

    test('fetchLogistikList sets loaded state on success', () async {
      when(() => mockRepository.getLogistikList())
          .thenAnswer((_) async => [sampleLogistik]);

      await controller.fetchLogistikList();

      expect(controller.status, LogistikStateStatus.loaded);
      expect(controller.logistikList.length, 1);
      expect(controller.errorMessage, isNull);
    });

    test('fetchLogistikList sets error state on ApiException', () async {
      when(() => mockRepository.getLogistikList()).thenThrow(
        const ApiException(message: 'Forbidden. Akses ditolak.'),
      );

      await controller.fetchLogistikList();

      expect(controller.status, LogistikStateStatus.error);
      expect(controller.errorMessage, 'Forbidden. Akses ditolak.');
    });

    test('fetchLogistikList sets error state on generic exception', () async {
      when(() => mockRepository.getLogistikList())
          .thenThrow(Exception('Unexpected'));

      await controller.fetchLogistikList();

      expect(controller.status, LogistikStateStatus.error);
      expect(controller.errorMessage, 'Terjadi kesalahan saat memuat data logistik.');
    });

    test('getLogistikForPenanganan filters by target penanganan id', () async {
      const logistik2 = LogistikModel(
        idLogistik: 'LOG-002',
        idPenanganan: 'PNG-002',
        namaLogistik: 'Masker Gas',
        jumlah: 10,
        satuan: 'Pcs',
        kondisi: 'Baik',
      );

      when(() => mockRepository.getLogistikList())
          .thenAnswer((_) async => [sampleLogistik, logistik2]);
      await controller.fetchLogistikList();

      final filtered = controller.getLogistikForPenanganan('PNG-001');
      expect(filtered.length, 1);
      expect(filtered.first.idLogistik, 'LOG-001');
    });

    test('createLogistik inserts logistik and updates state', () async {
      when(() => mockRepository.createLogistik(
            idPenanganan: 'PNG-001',
            namaLogistik: 'Selang Pemadam',
            jumlah: 4,
            satuan: 'Unit',
            kondisi: 'Baik',
            note: any(named: 'note'),
          )).thenAnswer((_) async => sampleLogistik);

      final result = await controller.createLogistik(
        idPenanganan: 'PNG-001',
        namaLogistik: 'Selang Pemadam',
        jumlah: 4,
        satuan: 'Unit',
        kondisi: 'Baik',
        note: 'Untuk memadamkan api',
      );

      expect(result, isNotNull);
      expect(result?.idLogistik, 'LOG-001');
      expect(controller.status, LogistikStateStatus.success);
      expect(controller.logistikList.length, 1);
    });

    test('createLogistik handles ValidationException', () async {
      when(() => mockRepository.createLogistik(
            idPenanganan: 'PNG-NOTFOUND',
            namaLogistik: any(named: 'namaLogistik'),
            jumlah: any(named: 'jumlah'),
            satuan: any(named: 'satuan'),
            kondisi: any(named: 'kondisi'),
            note: any(named: 'note'),
          )).thenThrow(ValidationException(
        message: 'Penanganan tidak ditemukan.',
        errors: {'id_penanganan': ['Penanganan tidak ditemukan.']},
      ));

      final result = await controller.createLogistik(
        idPenanganan: 'PNG-NOTFOUND',
        namaLogistik: 'Test',
        jumlah: 1,
        satuan: 'Pcs',
        kondisi: 'Baik',
      );

      expect(result, isNull);
      expect(controller.status, LogistikStateStatus.error);
      expect(controller.errorMessage, 'Penanganan tidak ditemukan.');
    });

    test('deleteLogistik removes item from local list', () async {
      when(() => mockRepository.getLogistikList())
          .thenAnswer((_) async => [sampleLogistik]);
      await controller.fetchLogistikList();

      when(() => mockRepository.deleteLogistik('LOG-001'))
          .thenAnswer((_) async => true);

      final success = await controller.deleteLogistik('LOG-001');

      expect(success, isTrue);
      expect(controller.status, LogistikStateStatus.success);
      expect(controller.logistikList.isEmpty, isTrue);
    });

    test('deleteLogistik returns false on failure', () async {
      when(() => mockRepository.getLogistikList())
          .thenAnswer((_) async => [sampleLogistik]);
      await controller.fetchLogistikList();

      when(() => mockRepository.deleteLogistik('LOG-001'))
          .thenAnswer((_) async => false);

      final success = await controller.deleteLogistik('LOG-001');

      expect(success, isFalse);
      expect(controller.status, LogistikStateStatus.error);
      expect(controller.logistikList.length, 1);
    });
  });
}