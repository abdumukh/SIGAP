import 'package:flutter_test/flutter_test.dart';
import 'package:sigap_mobile/data/models/alarm_model.dart';

void main() {
  group('AlarmModel Tests', () {
    test('parses complete alarm json payload correctly', () {
      final json = {
        'id_alarm': 'ALM-001',
        'id_pengguna': 'USR-001',
        'jenis_darurat': 'Kebakaran',
        'waktu_alarm': '2026-08-18T10:00:00.000000Z',
        'latitude': -6.2088000,
        'longitude': 106.8456000,
        'cuaca': 'Cerah',
        'lalu_lintas': 'Lancar',
        'status_alarm': 'menunggu',
        'created_at': '2026-08-18T10:00:00.000000Z',
        'updated_at': '2026-08-18T10:00:00.000000Z',
        'pengguna': {
          'id_pengguna': 'USR-001',
          'nama': 'Budi Pelapor',
          'no_hp': '081234567890',
        },
      };

      final alarm = AlarmModel.fromJson(json);

      expect(alarm.idAlarm, 'ALM-001');
      expect(alarm.idPengguna, 'USR-001');
      expect(alarm.jenisDarurat, 'Kebakaran');
      expect(alarm.latitude, -6.2088000);
      expect(alarm.longitude, 106.8456000);
      expect(alarm.cuaca, 'Cerah');
      expect(alarm.laluLintas, 'Lancar');
      expect(alarm.statusAlarm, 'menunggu');
      expect(alarm.isPending, isTrue);
      expect(alarm.isVerified, isFalse);
      expect(alarm.statusDisplay, 'Menunggu');
      expect(alarm.pelaporName, 'Budi Pelapor');
      expect(alarm.pelaporPhone, '081234567890');
      expect(alarm.coordinateDisplay, '-6.208800, 106.845600');
    });

    test('parses status transitions correctly for badge colors and getters', () {
      final verifiedJson = {
        'id_alarm': 'ALM-002',
        'id_pengguna': 'USR-002',
        'jenis_darurat': 'Medis Darurat',
        'latitude': -6.2,
        'longitude': 106.8,
        'status_alarm': 'diverifikasi',
      };

      final verifiedAlarm = AlarmModel.fromJson(verifiedJson);
      expect(verifiedAlarm.isVerified, isTrue);
      expect(verifiedAlarm.isPending, isFalse);
      expect(verifiedAlarm.statusDisplay, 'Diverifikasi');

      final rejectedJson = {
        'id_alarm': 'ALM-003',
        'id_pengguna': 'USR-003',
        'jenis_darurat': 'Palsu',
        'latitude': -6.2,
        'longitude': 106.8,
        'status_alarm': 'ditolak',
      };

      final rejectedAlarm = AlarmModel.fromJson(rejectedJson);
      expect(rejectedAlarm.isRejected, isTrue);
      expect(rejectedAlarm.statusDisplay, 'Ditolak');

      final completedJson = {
        'id_alarm': 'ALM-004',
        'id_pengguna': 'USR-004',
        'jenis_darurat': 'Bencana Alam',
        'latitude': -6.2,
        'longitude': 106.8,
        'status_alarm': 'selesai',
      };

      final completedAlarm = AlarmModel.fromJson(completedJson);
      expect(completedAlarm.isCompleted, isTrue);
      expect(completedAlarm.statusDisplay, 'Selesai');
    });

    test('toJson produces valid serializable map', () {
      final alarm = AlarmModel(
        idAlarm: 'ALM-001',
        idPengguna: 'USR-001',
        jenisDarurat: 'Kebakaran',
        latitude: -6.2,
        longitude: 106.8,
        statusAlarm: 'menunggu',
      );

      final json = alarm.toJson();
      expect(json['id_alarm'], 'ALM-001');
      expect(json['jenis_darurat'], 'Kebakaran');
      expect(json['status_alarm'], 'menunggu');
    });

    test('parses nested penugasan and penanganan workflow relations correctly', () {
      final json = {
        'id_alarm': 'ALM-010',
        'id_pengguna': 'USR-001',
        'jenis_darurat': 'Kebakaran',
        'latitude': -6.2,
        'longitude': 106.8,
        'status_alarm': 'diverifikasi',
        'penugasan': [
          {
            'id_penugasan': 'TGS-001',
            'id_alarm': 'ALM-010',
            'id_tim': 'TIM-001',
            'id_ketua_tim': 'PET-001',
            'status_penugasan': 'berangkat',
            'tim': {'id_tim': 'TIM-001', 'nama_tim': 'Tim Tim Alfa'},
          }
        ],
        'penanganan': {
          'id_penanganan': 'PNG-001',
          'id_alarm': 'ALM-010',
          'id_penugasan': 'TGS-001',
          'id_petugas': 'PET-001',
          'status_penanganan': 'di_lokasi',
          'dokumentasi_count': 3,
        },
      };

      final alarm = AlarmModel.fromJson(json);

      expect(alarm.hasPenugasan, isTrue);
      expect(alarm.hasPenanganan, isTrue);
      expect(alarm.latestPenugasan?.idPenugasan, 'TGS-001');
      expect(alarm.latestPenugasan?.timNama, 'Tim Tim Alfa');
      expect(alarm.penanganan?.idPenanganan, 'PNG-001');
      expect(alarm.penanganan?.statusPenanganan, 'di_lokasi');
      expect(alarm.dokumentasiCount, 3);
    });
  });
}
