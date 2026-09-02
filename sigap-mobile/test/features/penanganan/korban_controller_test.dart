import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/core/network/api_exceptions.dart';
import 'package:sigap_mobile/data/models/korban_model.dart';
import 'package:sigap_mobile/data/repositories/korban_repository.dart';
import 'package:sigap_mobile/features/penanganan/presentation/korban_controller.dart';

class MockKorbanRepository extends Mock implements KorbanRepository {}

void main() {
  late MockKorbanRepository mockRepository;
  late KorbanController controller;

  setUp(() {
    mockRepository = MockKorbanRepository();
    controller = KorbanController(repository: mockRepository);
  });

  group('KorbanController Tests', () {
    const sampleKorban = KorbanModel(
      idKorban: 'KRB-001',
      idPenanganan: 'PNG-001',
      namaKorban: 'Budi Santoso',
      jenisKelamin: 'L',
      usia: 35,
      kondisi: 'Luka Ringan',
      statusPenanganan: 'Dievakuasi ke RS',
    );

    test('initial state is correct', () {
      expect(controller.status, KorbanStateStatus.initial);
      expect(controller.korbanList, isEmpty);
      expect(controller.selectedKorban, isNull);
      expect(controller.errorMessage, isNull);
      expect(controller.successMessage, isNull);
      expect(controller.isLoading, isFalse);
      expect(controller.isCreating, isFalse);
      expect(controller.isDeleting, isFalse);
    });

    test('fetchKorbanList sets loaded state on success', () async {
      when(() => mockRepository.getKorbanList())
          .thenAnswer((_) async => [sampleKorban]);

      await controller.fetchKorbanList();

      expect(controller.status, KorbanStateStatus.loaded);
      expect(controller.korbanList.length, 1);
      expect(controller.errorMessage, isNull);
    });

    test('fetchKorbanList sets error state on ApiException', () async {
      when(() => mockRepository.getKorbanList()).thenThrow(
        const ApiException(message: 'Forbidden. Akses ditolak.'),
      );

      await controller.fetchKorbanList();

      expect(controller.status, KorbanStateStatus.error);
      expect(controller.errorMessage, 'Forbidden. Akses ditolak.');
    });

    test('fetchKorbanList sets error state on generic exception', () async {
      when(() => mockRepository.getKorbanList())
          .thenThrow(Exception('Unexpected'));

      await controller.fetchKorbanList();

      expect(controller.status, KorbanStateStatus.error);
      expect(controller.errorMessage, 'Terjadi kesalahan saat memuat data korban.');
    });

    test('getKorbanForPenanganan filters by target penanganan id', () async {
      const korban2 = KorbanModel(
        idKorban: 'KRB-002',
        idPenanganan: 'PNG-002',
        namaKorban: 'Siti',
        jenisKelamin: 'P',
        usia: 28,
        kondisi: 'Selamat',
        statusPenanganan: 'Ditampung',
      );

      when(() => mockRepository.getKorbanList())
          .thenAnswer((_) async => [sampleKorban, korban2]);
      await controller.fetchKorbanList();

      final filtered = controller.getKorbanForPenanganan('PNG-001');
      expect(filtered.length, 1);
      expect(filtered.first.idKorban, 'KRB-001');
    });

    test('createKorban inserts korban and updates state', () async {
      when(() => mockRepository.createKorban(
            idPenanganan: 'PNG-001',
            namaKorban: 'Budi Santoso',
            jenisKelamin: 'L',
            usia: 35,
            kondisi: 'Luka Ringan',
            statusPenanganan: 'Dievakuasi ke RS',
            note: any(named: 'note'),
          )).thenAnswer((_) async => sampleKorban);

      final result = await controller.createKorban(
        idPenanganan: 'PNG-001',
        namaKorban: 'Budi Santoso',
        jenisKelamin: 'L',
        usia: 35,
        kondisi: 'Luka Ringan',
        statusPenanganan: 'Dievakuasi ke RS',
        note: 'Perlu perawatan medis',
      );

      expect(result, isNotNull);
      expect(result?.idKorban, 'KRB-001');
      expect(controller.status, KorbanStateStatus.success);
      expect(controller.korbanList.length, 1);
    });

    test('createKorban handles ValidationException', () async {
      when(() => mockRepository.createKorban(
            idPenanganan: 'PNG-NOTFOUND',
            namaKorban: any(named: 'namaKorban'),
            jenisKelamin: any(named: 'jenisKelamin'),
            usia: any(named: 'usia'),
            kondisi: any(named: 'kondisi'),
            statusPenanganan: any(named: 'statusPenanganan'),
            note: any(named: 'note'),
          )).thenThrow(ValidationException(
        message: 'Penanganan tidak ditemukan.',
        errors: {'id_penanganan': ['Penanganan tidak ditemukan.']},
      ));

      final result = await controller.createKorban(
        idPenanganan: 'PNG-NOTFOUND',
        namaKorban: 'Test',
        jenisKelamin: 'L',
        usia: 25,
        kondisi: 'Baik',
        statusPenanganan: 'Selesai',
      );

      expect(result, isNull);
      expect(controller.status, KorbanStateStatus.error);
      expect(controller.errorMessage, 'Penanganan tidak ditemukan.');
    });

    test('deleteKorban removes item from local list', () async {
      when(() => mockRepository.getKorbanList())
          .thenAnswer((_) async => [sampleKorban]);
      await controller.fetchKorbanList();

      when(() => mockRepository.deleteKorban('KRB-001'))
          .thenAnswer((_) async => true);

      final success = await controller.deleteKorban('KRB-001');

      expect(success, isTrue);
      expect(controller.status, KorbanStateStatus.success);
      expect(controller.korbanList.isEmpty, isTrue);
    });

    test('double-submit protection prevents concurrent creates', () async {
      final completer = Completer<KorbanModel>();

      when(() => mockRepository.createKorban(
            idPenanganan: 'PNG-001',
            namaKorban: 'Budi Santoso',
            jenisKelamin: 'L',
            usia: 35,
            kondisi: 'Luka Ringan',
            statusPenanganan: 'Dievakuasi ke RS',
            note: any(named: 'note'),
          )).thenAnswer((_) => completer.future);

      // Start first create (won't complete yet)
      final future1 = controller.createKorban(
        idPenanganan: 'PNG-001',
        namaKorban: 'Budi Santoso',
        jenisKelamin: 'L',
        usia: 35,
        kondisi: 'Luka Ringan',
        statusPenanganan: 'Dievakuasi ke RS',
        note: null,
      );

      // Wait one microtask so isCreating becomes true
      await Future.microtask(() {});

      // Second create should return null due to double-submit protection
      final result2 = await controller.createKorban(
        idPenanganan: 'PNG-001',
        namaKorban: 'Test',
        jenisKelamin: 'P',
        usia: 25,
        kondisi: 'Baik',
        statusPenanganan: 'Selesai',
      );

      expect(result2, isNull);
      expect(controller.isCreating, isTrue);

      // Complete the first call to avoid pending futures
      completer.complete(sampleKorban);
      await future1;
    });
  });
}