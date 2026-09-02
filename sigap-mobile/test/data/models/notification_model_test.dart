import 'package:flutter_test/flutter_test.dart';
import 'package:sigap_mobile/data/models/notifikasi_model.dart';

void main() {
  group('NotifikasiModel Tests', () {
    test('parses notification JSON correctly', () {
      final json = {
        'id_notifikasi': 'NTF-001',
        'type': 'ALARM_CREATED',
        'title': 'Laporan Baru',
        'message': 'Laporan baru masuk.',
        'data': {'id_alarm': 'ALM-001'},
        'read_at': null,
        'created_at': '2026-08-27T10:00:00.000000Z',
        'updated_at': '2026-08-27T10:00:00.000000Z',
        'is_read': false,
      };

      final notif = NotifikasiModel.fromJson(json);

      expect(notif.idNotifikasi, 'NTF-001');
      expect(notif.type, 'ALARM_CREATED');
      expect(notif.title, 'Laporan Baru');
      expect(notif.message, 'Laporan baru masuk.');
      expect(notif.isRead, isFalse);
      expect(notif.isUnread, isTrue);
      expect(notif.typeLabel, 'Laporan Baru');
      expect(notif.entityId, 'ALM-001');
      expect(notif.entityRoute, 'alarmDetail');
    });

    test('handles read status correctly', () {
      final json = {
        'id_notifikasi': 'NTF-002',
        'type': 'PENANGANAN_COMPLETED',
        'title': 'Penanganan Selesai',
        'message': 'Penanganan telah selesai.',
        'read_at': '2026-08-27T11:00:00.000000Z',
        'is_read': true,
      };

      final notif = NotifikasiModel.fromJson(json);

      expect(notif.isRead, isTrue);
      expect(notif.isUnread, isFalse);
      expect(notif.typeLabel, 'Penanganan Selesai');
    });
  });
}
