import 'package:flutter_test/flutter_test.dart';
import 'package:sigap_mobile/data/models/penanganan_model.dart';

void main() {
  group('PenangananModel Tests', () {
    test('parses Penanganan JSON with nested alarm, penugasan, and petugas', () {
      final json = {
        'id_penanganan': 'PNG-001',
        'id_alarm': 'ALM-001',
        'id_penugasan': 'TGS-001',
        'id_petugas': 'PTG-001',
        'waktu_berangkat': '2026-08-20T10:00:00Z',
        'waktu_tiba': '2026-08-20T10:15:00Z',
        'waktu_selesai': null,
        'status_penanganan': 'di_lokasi',
        'note': 'Melakukan pemadaman api di lantai 2.',
        'created_at': '2026-08-20T10:00:00Z',
        'updated_at': '2026-08-20T10:15:00Z',
        'alarm': {
          'id_alarm': 'ALM-001',
          'jenis_darurat': 'Kebakaran',
          'waktu_alarm': '2026-08-20T09:50:00Z',
          'latitude': -6.2088,
          'longitude': 106.8456,
          'status_alarm': 'diverifikasi',
        },
        'penugasan': {
          'id_penugasan': 'TGS-001',
          'id_alarm': 'ALM-001',
          'id_tim': 'TIM-001',
          'id_ketua_tim': 'PTG-001',
          'status_penugasan': 'proses',
        },
        'petugas': {
          'id_petugas': 'PTG-001',
          'nama_petugas': 'Ahmad Petugas',
          'role': 'petugas',
        },
      };

      final model = PenangananModel.fromJson(json);

      expect(model.idPenanganan, 'PNG-001');
      expect(model.idAlarm, 'ALM-001');
      expect(model.idPenugasan, 'TGS-001');
      expect(model.idPetugas, 'PTG-001');
      expect(model.waktuBerangkat, '2026-08-20T10:00:00Z');
      expect(model.waktuTiba, '2026-08-20T10:15:00Z');
      expect(model.waktuSelesai, isNull);
      expect(model.statusPenanganan, 'di_lokasi');
      expect(model.note, 'Melakukan pemadaman api di lantai 2.');

      // Nested alarm
      expect(model.alarmJenisDarurat, 'Kebakaran');
      expect(model.alarmLatitude, -6.2088);
      expect(model.alarmLongitude, 106.8456);
      expect(model.alarmStatus, 'diverifikasi');

      // Nested penugasan
      expect(model.penugasanId, 'TGS-001');
      expect(model.penugasanIdTim, 'TIM-001');
      expect(model.penugasanStatus, 'proses');

      // Nested petugas
      expect(model.petugasNama, 'Ahmad Petugas');
      expect(model.petugasRole, 'petugas');

      // Helpers
      expect(model.isMenujuLokasi, isFalse);
      expect(model.isDiLokasi, isTrue);
      expect(model.isSelesai, isFalse);
      expect(model.statusDisplay, 'Tiba di Lokasi');
      expect(model.statusLabel, 'Tiba di Lokasi');
      expect(model.nextValidStatus, 'selesai');
      expect(model.nextActionLabel, 'SELESAIKAN PENANGANAN');
    });

    test('verifies status helpers for all stages', () {
      const p1 = PenangananModel(
        idPenanganan: 'PNG-001',
        idAlarm: 'ALM-001',
        idPenugasan: 'TGS-001',
        idPetugas: 'PTG-001',
        statusPenanganan: 'menuju_lokasi',
      );
      expect(p1.isMenujuLokasi, isTrue);
      expect(p1.statusDisplay, 'Menuju Lokasi');
      expect(p1.nextValidStatus, 'di_lokasi');
      expect(p1.nextActionLabel, 'SUDAH TIBA DI LOKASI');

      const p2 = PenangananModel(
        idPenanganan: 'PNG-002',
        idAlarm: 'ALM-002',
        idPenugasan: 'TGS-002',
        idPetugas: 'PTG-002',
        statusPenanganan: 'selesai',
      );
      expect(p2.isSelesai, isTrue);
      expect(p2.statusDisplay, 'Penanganan Selesai');
      expect(p2.nextValidStatus, isNull);
      expect(p2.nextActionLabel, isNull);
    });

    test('toJson serializes core fields correctly', () {
      const model = PenangananModel(
        idPenanganan: 'PNG-003',
        idAlarm: 'ALM-003',
        idPenugasan: 'TGS-003',
        idPetugas: 'PTG-003',
        waktuBerangkat: '2026-08-20T10:00:00Z',
        waktuTiba: '2026-08-20T10:20:00Z',
        waktuSelesai: '2026-08-20T11:00:00Z',
        statusPenanganan: 'selesai',
        note: 'Penanganan tuntas.',
      );

      final json = model.toJson();

      expect(json['id_penanganan'], 'PNG-003');
      expect(json['id_alarm'], 'ALM-003');
      expect(json['id_penugasan'], 'TGS-003');
      expect(json['id_petugas'], 'PTG-003');
      expect(json['status_penanganan'], 'selesai');
      expect(json['note'], 'Penanganan tuntas.');
    });
  });
}
