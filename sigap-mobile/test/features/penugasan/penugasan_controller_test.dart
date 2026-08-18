import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/core/network/api_exceptions.dart';
import 'package:sigap_mobile/data/models/penugasan_model.dart';
import 'package:sigap_mobile/data/repositories/penugasan_repository.dart';
import 'package:sigap_mobile/features/penugasan/presentation/penugasan_controller.dart';

class MockPenugasanRepository extends Mock implements PenugasanRepository {}

void main() {
  late MockPenugasanRepository mockRepository;
  late PenugasanController controller;

  setUp(() {
    mockRepository = MockPenugasanRepository();
    controller = PenugasanController(repository: mockRepository);
  });

  group('PenugasanController Tests', () {
    const testPenugasan = PenugasanModel(
      idPenugasan: 'TGS-001',
      idAlarm: 'ALM-001',
      idTim: 'TIM-001',
      idKetuaTim: 'PTG-001',
      statusPenugasan: 'menunggu',
    );

    test('fetchPenugasanList sets loaded state on success', () async {
      when(() => mockRepository.getPenugasanList())
          .thenAnswer((_) async => [testPenugasan]);

      expect(controller.status, PenugasanStateStatus.initial);

      await controller.fetchPenugasanList();

      expect(controller.status, PenugasanStateStatus.loaded);
      expect(controller.penugasanList.length, 1);
      expect(controller.penugasanList.first.idPenugasan, 'TGS-001');
    });

    test('fetchPenugasanList sets error state on failure', () async {
      when(() => mockRepository.getPenugasanList()).thenThrow(
        const ServerException(message: 'Server error'),
      );

      await controller.fetchPenugasanList();

      expect(controller.status, PenugasanStateStatus.error);
      expect(controller.errorMessage, 'Server error');
    });

    test('createPenugasan inserts new assignment and updates state', () async {
      when(() => mockRepository.createPenugasan(
            idAlarm: any(named: 'idAlarm'),
            idTim: any(named: 'idTim'),
            idKetuaTim: any(named: 'idKetuaTim'),
            idPetugasArmada: any(named: 'idPetugasArmada'),
            idArmada: any(named: 'idArmada'),
            waktuPenugasan: any(named: 'waktuPenugasan'),
            note: any(named: 'note'),
          )).thenAnswer((_) async => testPenugasan);

      final result = await controller.createPenugasan(
        idAlarm: 'ALM-001',
        idTim: 'TIM-001',
        idKetuaTim: 'PTG-001',
      );

      expect(result, isNotNull);
      expect(result!.idPenugasan, 'TGS-001');
      expect(controller.status, PenugasanStateStatus.success);
      expect(controller.penugasanList.length, 1);
    });

    test('filter penugasan by status works correctly', () async {
      const p1 = PenugasanModel(
        idPenugasan: 'TGS-001',
        idAlarm: 'ALM-001',
        idTim: 'TIM-001',
        idKetuaTim: 'PTG-001',
        statusPenugasan: 'menunggu',
      );
      const p2 = PenugasanModel(
        idPenugasan: 'TGS-002',
        idAlarm: 'ALM-002',
        idTim: 'TIM-002',
        idKetuaTim: 'PTG-002',
        statusPenugasan: 'proses',
      );

      when(() => mockRepository.getPenugasanList())
          .thenAnswer((_) async => [p1, p2]);

      await controller.fetchPenugasanList();
      expect(controller.filteredPenugasanList.length, 2);

      controller.setFilter('proses');
      expect(controller.filteredPenugasanList.length, 1);
      expect(controller.filteredPenugasanList.first.idPenugasan, 'TGS-002');
    });
  });
}
