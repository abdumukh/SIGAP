import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/data/repositories/anggota_tim_repository.dart';
import 'package:sigap_mobile/data/services/anggota_tim_service.dart';

class MockAnggotaTimService extends Mock implements AnggotaTimService {}

void main() {
  late MockAnggotaTimService mockService;
  late AnggotaTimRepository repository;

  setUp(() {
    mockService = MockAnggotaTimService();
    repository = AnggotaTimRepository(service: mockService);
  });

  group('AnggotaTimRepository Tests', () {
    final sampleMemberMap = {
      'id_anggota_tim': 'AGT-001',
      'id_tim': 'TIM-001',
      'id_petugas': 'PTG-001',
      'status_anggota': 'aktif',
      'petugas': {
        'id_petugas': 'PTG-001',
        'nama_petugas': 'Ahmad Ketua',
        'role': 'ketua_tim',
      }
    };

    test('getAnggota returns parsed list of AnggotaTimModel', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/tim/TIM-001/anggota'),
        data: {
          'status': 'success',
          'data': [sampleMemberMap],
        },
      );

      when(() => mockService.getAnggota('TIM-001'))
          .thenAnswer((_) async => response);

      final members = await repository.getAnggota('TIM-001');

      expect(members.length, 1);
      expect(members.first.idAnggotaTim, 'AGT-001');
      expect(members.first.displayName, 'Ahmad Ketua');
    });

    test('addAnggota posts data and returns created member', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/tim/TIM-001/anggota'),
        data: {
          'status': 'success',
          'data': sampleMemberMap,
        },
      );

      when(() => mockService.addAnggota('TIM-001', any()))
          .thenAnswer((_) async => response);

      final created = await repository.addAnggota(
        'TIM-001',
        idPetugas: 'PTG-001',
      );

      expect(created.idPetugas, 'PTG-001');
    });

    test('updateAnggota updates member status', () async {
      final updatedMap = Map<String, dynamic>.from(sampleMemberMap);
      updatedMap['status_anggota'] = 'nonaktif';

      final response = Response(
        requestOptions: RequestOptions(path: '/tim/TIM-001/anggota/AGT-001'),
        data: {
          'status': 'success',
          'data': updatedMap,
        },
      );

      when(() => mockService.updateAnggota('TIM-001', 'AGT-001', any()))
          .thenAnswer((_) async => response);

      final updated = await repository.updateAnggota(
        'TIM-001',
        'AGT-001',
        statusAnggota: 'nonaktif',
      );

      expect(updated.isNonaktif, isTrue);
    });

    test('removeAnggota deletes member', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/tim/TIM-001/anggota/AGT-001'),
        data: {
          'status': 'success',
          'data': sampleMemberMap,
        },
      );

      when(() => mockService.removeAnggota('TIM-001', 'AGT-001'))
          .thenAnswer((_) async => response);

      final removed = await repository.removeAnggota('TIM-001', 'AGT-001');

      expect(removed.idAnggotaTim, 'AGT-001');
    });
  });
}
