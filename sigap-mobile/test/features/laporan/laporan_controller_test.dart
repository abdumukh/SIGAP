import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/core/network/api_exceptions.dart';
import 'package:sigap_mobile/data/models/laporan_model.dart';
import 'package:sigap_mobile/data/repositories/laporan_repository.dart';
import 'package:sigap_mobile/features/laporan/presentation/laporan_controller.dart';

class MockLaporanRepository extends Mock implements LaporanRepository {}

class FakeLaporanFilter extends Fake implements LaporanFilter {}

void main() {
  late MockLaporanRepository mockRepository;
  late LaporanController controller;

  setUpAll(() {
    registerFallbackValue(FakeLaporanFilter());
  });

  setUp(() {
    mockRepository = MockLaporanRepository();
    controller = LaporanController(repository: mockRepository);
  });

  group('LaporanController', () {
    test('initial state is correct', () {
      expect(controller.status, LaporanStateStatus.initial);
      expect(controller.data, isNull);
      expect(controller.errorMessage, isNull);
      expect(controller.isLoading, false);
    });

    test('fetchLaporan sets loaded on success', () async {
      const mockModel = LaporanModel(
        type: 'alarm',
        total: 5,
        items: [],
      );

      when(() => mockRepository.getLaporan(filter: any(named: 'filter')))
          .thenAnswer((_) async => mockModel);

      await controller.fetchLaporan(type: 'alarm');

      expect(controller.status, LaporanStateStatus.loaded);
      expect(controller.data, isNotNull);
      expect(controller.data!.type, 'alarm');
    });

    test('fetchLaporan sets error on ApiException', () async {
      when(() => mockRepository.getLaporan(filter: any(named: 'filter')))
          .thenThrow(ForbiddenException(message: 'Akses ditolak'));

      await controller.fetchLaporan(type: 'alarm');

      expect(controller.status, LaporanStateStatus.error);
      expect(controller.errorMessage, 'Akses ditolak');
    });

    test('fetchLaporan updates currentFilter with passed params', () async {
      when(() => mockRepository.getLaporan(filter: any(named: 'filter')))
          .thenAnswer((_) async => const LaporanModel(type: 'penugasan', total: 0, items: []));

      await controller.fetchLaporan(
        type: 'penugasan',
        startDate: '2026-01-01',
        status: 'selesai',
      );

      expect(controller.currentFilter.type, 'penugasan');
      expect(controller.currentFilter.startDate, '2026-01-01');
      expect(controller.currentFilter.status, 'selesai');
    });

    test('clearFilters refetches with current type', () async {
      when(() => mockRepository.getLaporan(filter: any(named: 'filter')))
          .thenAnswer((_) async => const LaporanModel(type: 'alarm', total: 0, items: []));

      await controller.fetchLaporan(type: 'alarm', startDate: '2026-01-01');
      await controller.clearFilters();

      expect(controller.currentFilter.startDate, isNull);
      expect(controller.currentFilter.type, 'alarm');
    });

    test('reset clears all state', () {
      controller.reset();

      expect(controller.status, LaporanStateStatus.initial);
      expect(controller.data, isNull);
    });
  });
}