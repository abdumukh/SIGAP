import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/core/network/api_exceptions.dart';
import 'package:sigap_mobile/data/models/tim_model.dart';
import 'package:sigap_mobile/data/repositories/tim_repository.dart';
import 'package:sigap_mobile/features/tim/presentation/tim_controller.dart';

class MockTimRepository extends Mock implements TimRepository {}

void main() {
  late MockTimRepository mockRepository;
  late TimController controller;

  setUp(() {
    mockRepository = MockTimRepository();
    controller = TimController(repository: mockRepository);
  });

  group('TimController Tests', () {
    const testTim = TimModel(
      idTim: 'TIM-001',
      namaTim: 'Tim Reaksi Cepat 1',
      statusTim: 'aktif',
    );

    test('fetchTimList sets loaded state on success', () async {
      when(() => mockRepository.getTimList())
          .thenAnswer((_) async => [testTim]);

      expect(controller.status, TimStateStatus.initial);

      await controller.fetchTimList();

      expect(controller.status, TimStateStatus.loaded);
      expect(controller.timList.length, 1);
      expect(controller.timList.first.idTim, 'TIM-001');
    });

    test('fetchTimList sets error state on failure', () async {
      when(() => mockRepository.getTimList()).thenThrow(
        const ServerException(message: 'Server error occurred'),
      );

      await controller.fetchTimList();

      expect(controller.status, TimStateStatus.error);
      expect(controller.errorMessage, 'Server error occurred');
      expect(controller.timList, isEmpty);
    });

    test('createTim inserts new tim and sets success state', () async {
      when(() => mockRepository.createTim(
            namaTim: any(named: 'namaTim'),
            note: any(named: 'note'),
            statusTim: any(named: 'statusTim'),
          )).thenAnswer((_) async => testTim);

      final result = await controller.createTim(
        namaTim: 'Tim Reaksi Cepat 1',
      );

      expect(result, isNotNull);
      expect(result!.idTim, 'TIM-001');
      expect(controller.status, TimStateStatus.success);
      expect(controller.timList.length, 1);
      expect(controller.successMessage, isNotNull);
    });

    test('updateTim updates local tim and selectedTim', () async {
      const updatedTim = TimModel(
        idTim: 'TIM-001',
        namaTim: 'Tim Alpha Updated',
        statusTim: 'aktif',
      );

      when(() => mockRepository.getTimList())
          .thenAnswer((_) async => [testTim]);
      when(() => mockRepository.updateTim(
            'TIM-001',
            namaTim: any(named: 'namaTim'),
            note: any(named: 'note'),
            statusTim: any(named: 'statusTim'),
          )).thenAnswer((_) async => updatedTim);

      await controller.fetchTimList();
      final success = await controller.updateTim(
        'TIM-001',
        namaTim: 'Tim Alpha Updated',
      );

      expect(success, isTrue);
      expect(controller.timList.first.namaTim, 'Tim Alpha Updated');
      expect(controller.status, TimStateStatus.success);
    });

    test('deleteTim deactivates team and updates local list', () async {
      const deactivatedTim = TimModel(
        idTim: 'TIM-001',
        namaTim: 'Tim Reaksi Cepat 1',
        statusTim: 'nonaktif',
      );

      when(() => mockRepository.getTimList())
          .thenAnswer((_) async => [testTim]);
      when(() => mockRepository.deleteTim('TIM-001'))
          .thenAnswer((_) async => deactivatedTim);

      await controller.fetchTimList();
      final success = await controller.deleteTim('TIM-001');

      expect(success, isTrue);
      expect(controller.timList.first.isNonaktif, isTrue);
    });
  });
}
