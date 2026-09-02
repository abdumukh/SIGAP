import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/data/models/notifikasi_model.dart';
import 'package:sigap_mobile/data/repositories/notifikasi_repository.dart';
import 'package:sigap_mobile/features/notifikasi/presentation/notifikasi_controller.dart';

class MockNotifikasiRepository extends Mock implements NotifikasiRepository {}

void main() {
  late MockNotifikasiRepository mockRepo;
  late NotifikasiController controller;

  setUp(() {
    mockRepo = MockNotifikasiRepository();
    controller = NotifikasiController(repository: mockRepo);
  });

  group('NotifikasiController Tests', () {
    test('fetchNotifikasiList updates notifikasiList and unreadCount', () async {
      final list = [
        const NotifikasiModel(
          idNotifikasi: 'NTF-001',
          type: 'ALARM_CREATED',
          title: 'Laporan 1',
          message: 'Pesan 1',
          isRead: false,
        ),
        const NotifikasiModel(
          idNotifikasi: 'NTF-002',
          type: 'ALARM_VERIFIED',
          title: 'Laporan 2',
          message: 'Pesan 2',
          isRead: true,
        ),
      ];

      when(() => mockRepo.getNotifikasiList()).thenAnswer((_) async => list);

      await controller.fetchNotifikasiList();

      expect(controller.notifikasiList.length, 2);
      expect(controller.unreadCount, 1);
      expect(controller.isLoading, isFalse);
    });

    test('markAsRead marks notification as read and refreshes', () async {
      when(() => mockRepo.markAsRead('NTF-001')).thenAnswer(
        (_) async => const NotifikasiModel(
          idNotifikasi: 'NTF-001',
          type: 'ALARM_CREATED',
          title: 'Laporan 1',
          message: 'Pesan 1',
          isRead: true,
        ),
      );
      when(() => mockRepo.getNotifikasiList()).thenAnswer((_) async => []);

      await controller.markAsRead('NTF-001');

      verify(() => mockRepo.markAsRead('NTF-001')).called(1);
    });

    test('markAllAsRead marks all notifications as read and refreshes', () async {
      when(() => mockRepo.markAllAsRead()).thenAnswer((_) async => 3);
      when(() => mockRepo.getNotifikasiList()).thenAnswer((_) async => []);

      await controller.markAllAsRead();

      verify(() => mockRepo.markAllAsRead()).called(1);
    });
  });
}
