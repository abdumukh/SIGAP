import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/core/network/api_exceptions.dart';
import 'package:sigap_mobile/data/models/penanganan_model.dart';
import 'package:sigap_mobile/data/repositories/penanganan_repository.dart';
import 'package:sigap_mobile/features/penanganan/presentation/penanganan_controller.dart';

class MockPenangananRepository extends Mock implements PenangananRepository {}

void main() {
  late MockPenangananRepository mockRepository;
  late PenangananController controller;

  setUp(() {
    mockRepository = MockPenangananRepository();
    controller = PenangananController(repository: mockRepository);
  });

  group('PenangananController Tests', () {
    const samplePenanganan = PenangananModel(
      idPenanganan: 'PNG-001',
      idAlarm: 'ALM-001',
      idPenugasan: 'TGS-001',
      idPetugas: 'PTG-001',
      statusPenanganan: 'menuju_lokasi',
    );

    test('fetchPenangananList sets loaded state on success', () async {
      when(() => mockRepository.getPenangananList())
          .thenAnswer((_) async => [samplePenanganan]);

      await controller.fetchPenangananList();

      expect(controller.status, PenangananStateStatus.loaded);
      expect(controller.penangananList.length, 1);
      expect(controller.penangananList.first.idPenanganan, 'PNG-001');
      expect(controller.errorMessage, isNull);
    });

    test('fetchPenangananList sets error state on ApiException', () async {
      when(() => mockRepository.getPenangananList()).thenThrow(
        const ApiException(message: 'Forbidden. Akses ditolak.'),
      );

      await controller.fetchPenangananList();

      expect(controller.status, PenangananStateStatus.error);
      expect(controller.errorMessage, 'Forbidden. Akses ditolak.');
    });

    test('fetchPenangananDetail sets selectedPenanganan on success', () async {
      when(() => mockRepository.getPenangananById('PNG-001'))
          .thenAnswer((_) async => samplePenanganan);

      await controller.fetchPenangananDetail('PNG-001');

      expect(controller.status, PenangananStateStatus.loaded);
      expect(controller.selectedPenanganan?.idPenanganan, 'PNG-001');
    });

    test('createPenanganan inserts created record at top and sets success', () async {
      when(() => mockRepository.createPenanganan(
            idPenugasan: 'TGS-001',
            note: 'Berangkat sekarang',
          )).thenAnswer((_) async => samplePenanganan);

      final result = await controller.createPenanganan(
        idPenugasan: 'TGS-001',
        note: 'Berangkat sekarang',
      );

      expect(result, isNotNull);
      expect(result?.idPenanganan, 'PNG-001');
      expect(controller.status, PenangananStateStatus.success);
      expect(controller.penangananList.length, 1);
    });

    test('updateStatus updates local list and selectedPenanganan', () async {
      const updatedModel = PenangananModel(
        idPenanganan: 'PNG-001',
        idAlarm: 'ALM-001',
        idPenugasan: 'TGS-001',
        idPetugas: 'PTG-001',
        statusPenanganan: 'di_lokasi',
      );

      when(() => mockRepository.getPenangananById('PNG-001'))
          .thenAnswer((_) async => samplePenanganan);
      await controller.fetchPenangananDetail('PNG-001');

      when(() => mockRepository.updatePenangananStatus(
            'PNG-001',
            statusPenanganan: 'di_lokasi',
            note: any(named: 'note'),
          )).thenAnswer((_) async => updatedModel);

      final updated = await controller.updateStatus('PNG-001', targetStatus: 'di_lokasi');

      expect(updated?.statusPenanganan, 'di_lokasi');
      expect(controller.selectedPenanganan?.statusPenanganan, 'di_lokasi');
      expect(controller.status, PenangananStateStatus.success);
    });

    test('invalid status transition from menuju_lokasi to selesai is prevented', () async {
      when(() => mockRepository.getPenangananById('PNG-001'))
          .thenAnswer((_) async => samplePenanganan);
      await controller.fetchPenangananDetail('PNG-001');

      final result = await controller.updateStatus('PNG-001', targetStatus: 'selesai');

      expect(result, isNull);
      expect(controller.status, PenangananStateStatus.error);
      expect(controller.errorMessage, contains('Transisi status'));
      verifyNever(() => mockRepository.updatePenangananStatus(any(), statusPenanganan: any(named: 'statusPenanganan')));
    });

    test('update status when already selesai is rejected', () async {
      const selesaiModel = PenangananModel(
        idPenanganan: 'PNG-001',
        idAlarm: 'ALM-001',
        idPenugasan: 'TGS-001',
        idPetugas: 'PTG-001',
        statusPenanganan: 'selesai',
      );

      when(() => mockRepository.getPenangananById('PNG-001'))
          .thenAnswer((_) async => selesaiModel);
      await controller.fetchPenangananDetail('PNG-001');

      final result = await controller.updateStatus('PNG-001', targetStatus: 'di_lokasi');

      expect(result, isNull);
      expect(controller.status, PenangananStateStatus.error);
      expect(controller.errorMessage, contains('sudah selesai'));
    });

    test('filters penanganan list by status', () async {
      const p1 = PenangananModel(
        idPenanganan: 'PNG-001',
        idAlarm: 'ALM-001',
        idPenugasan: 'TGS-001',
        idPetugas: 'PTG-001',
        statusPenanganan: 'menuju_lokasi',
      );
      const p2 = PenangananModel(
        idPenanganan: 'PNG-002',
        idAlarm: 'ALM-002',
        idPenugasan: 'TGS-002',
        idPetugas: 'PTG-002',
        statusPenanganan: 'selesai',
      );

      when(() => mockRepository.getPenangananList())
          .thenAnswer((_) async => [p1, p2]);

      await controller.fetchPenangananList();

      expect(controller.filteredPenangananList.length, 2);

      controller.setFilter('selesai');
      expect(controller.filteredPenangananList.length, 1);
      expect(controller.filteredPenangananList.first.idPenanganan, 'PNG-002');
    });
  });
}
