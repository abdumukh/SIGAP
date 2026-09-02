import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/core/network/api_exceptions.dart';
import 'package:sigap_mobile/data/models/anggota_tim_model.dart';
import 'package:sigap_mobile/data/repositories/anggota_tim_repository.dart';
import 'package:sigap_mobile/features/tim/presentation/anggota_tim_controller.dart';

class MockAnggotaTimRepository extends Mock implements AnggotaTimRepository {}

void main() {
  late MockAnggotaTimRepository mockRepository;
  late AnggotaTimController controller;

  setUp(() {
    mockRepository = MockAnggotaTimRepository();
    controller = AnggotaTimController(repository: mockRepository);
  });

  group('AnggotaTimController Tests', () {
    const testMember = AnggotaTimModel(
      idAnggotaTim: 'AGT-001',
      idTim: 'TIM-001',
      idPetugas: 'PTG-001',
      namaPetugas: 'Budi Petugas',
      role: 'petugas',
      statusAnggota: 'aktif',
    );

    test('fetchMembers sets loaded state on success', () async {
      when(() => mockRepository.getAnggota('TIM-001'))
          .thenAnswer((_) async => [testMember]);

      expect(controller.status, AnggotaStateStatus.initial);

      await controller.fetchMembers('TIM-001');

      expect(controller.status, AnggotaStateStatus.loaded);
      expect(controller.members.length, 1);
      expect(controller.members.first.idAnggotaTim, 'AGT-001');
    });

    test('fetchMembers sets error state on failure', () async {
      when(() => mockRepository.getAnggota('TIM-001')).thenThrow(
        const ServerException(message: 'Gagal memuat anggota'),
      );

      await controller.fetchMembers('TIM-001');

      expect(controller.status, AnggotaStateStatus.error);
      expect(controller.errorMessage, 'Gagal memuat anggota');
      expect(controller.members, isEmpty);
    });

    test('addMember inserts new member and updates state', () async {
      when(() => mockRepository.addAnggota(
            'TIM-001',
            idPetugas: 'PTG-001',
            tanggalMasuk: any(named: 'tanggalMasuk'),
            statusAnggota: any(named: 'statusAnggota'),
          )).thenAnswer((_) async => testMember);

      final success = await controller.addMember(
        'TIM-001',
        idPetugas: 'PTG-001',
      );

      expect(success, isTrue);
      expect(controller.status, AnggotaStateStatus.success);
      expect(controller.members.length, 1);
      expect(controller.successMessage, 'Anggota tim berhasil ditambahkan.');
    });

    test('updateMemberStatus updates existing member in list', () async {
      const updatedMember = AnggotaTimModel(
        idAnggotaTim: 'AGT-001',
        idTim: 'TIM-001',
        idPetugas: 'PTG-001',
        statusAnggota: 'nonaktif',
      );

      when(() => mockRepository.getAnggota('TIM-001'))
          .thenAnswer((_) async => [testMember]);
      when(() => mockRepository.updateAnggota(
            'TIM-001',
            'AGT-001',
            statusAnggota: 'nonaktif',
          )).thenAnswer((_) async => updatedMember);

      await controller.fetchMembers('TIM-001');
      final success = await controller.updateMemberStatus(
        'TIM-001',
        'AGT-001',
        statusAnggota: 'nonaktif',
      );

      expect(success, isTrue);
      expect(controller.members.first.isNonaktif, isTrue);
      expect(controller.status, AnggotaStateStatus.success);
    });

    test('removeMember deactivates member and updates state', () async {
      const removedMember = AnggotaTimModel(
        idAnggotaTim: 'AGT-001',
        idTim: 'TIM-001',
        idPetugas: 'PTG-001',
        statusAnggota: 'nonaktif',
      );

      when(() => mockRepository.getAnggota('TIM-001'))
          .thenAnswer((_) async => [testMember]);
      when(() => mockRepository.removeAnggota('TIM-001', 'AGT-001'))
          .thenAnswer((_) async => removedMember);

      await controller.fetchMembers('TIM-001');
      final success = await controller.removeMember('TIM-001', 'AGT-001');

      expect(success, isTrue);
      expect(controller.members.first.isNonaktif, isTrue);
      expect(controller.status, AnggotaStateStatus.success);
    });
  });
}
