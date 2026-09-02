import 'package:flutter_test/flutter_test.dart';
import 'package:sigap_mobile/data/models/penugasan_model.dart';

void main() {
  group('PenugasanModel Tests', () {
    test('parses Penugasan JSON with nested alarm, tim, ketua, petugas_armada, and armada', () {
      final json = {
        'id_penugasan': 'TGS-001',
        'id_alarm': 'ALM-001',
        'id_tim': 'TIM-001',
        'id_ketua_tim': 'PTG-001',
        'id_petugas_armada': 'PTG-002',
        'id_armada': 'ARM-001',
        'waktu_penugasan': '2026-08-18T10:30:00Z',
        'status_penugasan': 'menunggu',
        'note': 'Siapkan tabung oksigen dan APAR.',
        'alarm': {
          'id_alarm': 'ALM-001',
          'jenis_darurat': 'Kebakaran',
          'status_alarm': 'diverifikasi',
          'latitude': -6.2088,
          'longitude': 106.8456,
        },
        'tim': {
          'id_tim': 'TIM-001',
          'nama_tim': 'Tim Reaksi Cepat 1',
          'status_tim': 'aktif',
        },
        'ketua_tim': {
          'id_petugas': 'PTG-001',
          'nama_petugas': 'Ahmad Ketua',
          'role': 'ketua_tim',
        },
        'petugas_armada': {
          'id_petugas': 'PTG-002',
          'nama_petugas': 'Bambang Driver',
          'role': 'petugas',
        },
        'armada': {
          'id_armada': 'ARM-001',
          'nama_armada': 'Damkar 01',
          'jenis_armada': 'Mobil Damkar',
          'nomor_kendaraan': 'B 1234 CD',
          'status_armada': 'digunakan',
        },
      };

      final penugasan = PenugasanModel.fromJson(json);

      expect(penugasan.idPenugasan, 'TGS-001');
      expect(penugasan.idAlarm, 'ALM-001');
      expect(penugasan.idTim, 'TIM-001');
      expect(penugasan.idKetuaTim, 'PTG-001');
      expect(penugasan.idPetugasArmada, 'PTG-002');
      expect(penugasan.idArmada, 'ARM-001');
      expect(penugasan.statusPenugasan, 'menunggu');
      expect(penugasan.isMenunggu, isTrue);
      expect(penugasan.statusDisplay, 'Menunggu');
      expect(penugasan.hasArmada, isTrue);

      // Nested checks
      expect(penugasan.alarmJenisDarurat, 'Kebakaran');
      expect(penugasan.alarmLatitude, -6.2088);
      expect(penugasan.timNama, 'Tim Reaksi Cepat 1');
      expect(penugasan.ketuaTimNama, 'Ahmad Ketua');
      expect(penugasan.petugasArmadaNama, 'Bambang Driver');
      expect(penugasan.armadaNama, 'Damkar 01');
      expect(penugasan.armadaNomor, 'B 1234 CD');
    });

    test('statusDisplay handles all status transitions', () {
      const p1 = PenugasanModel(
        idPenugasan: 'TGS-002',
        idAlarm: 'ALM-002',
        idTim: 'TIM-001',
        idKetuaTim: 'PTG-001',
        statusPenugasan: 'berangkat',
      );
      expect(p1.isBerangkat, isTrue);
      expect(p1.statusDisplay, 'Dalam Proses');

      const p2 = PenugasanModel(
        idPenugasan: 'TGS-003',
        idAlarm: 'ALM-003',
        idTim: 'TIM-001',
        idKetuaTim: 'PTG-001',
        statusPenugasan: 'selesai',
      );
      expect(p2.isSelesai, isTrue);
      expect(p2.statusDisplay, 'Selesai');

      const p3 = PenugasanModel(
        idPenugasan: 'TGS-004',
        idAlarm: 'ALM-004',
        idTim: 'TIM-001',
        idKetuaTim: 'PTG-001',
        statusPenugasan: 'diterima',
      );
      expect(p3.isDiterima, isTrue);
      expect(p3.statusDisplay, 'Diterima');
    });
  });
}
