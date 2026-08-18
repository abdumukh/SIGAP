import 'package:flutter_test/flutter_test.dart';
import 'package:sigap_mobile/data/models/tim_model.dart';

void main() {
  group('TimModel Tests', () {
    test('parses complete Tim JSON payload with nested members correctly', () {
      final json = {
        'id_tim': 'TIM-001',
        'nama_tim': 'Tim Reaksi Cepat 1',
        'note': 'Wilayah Operasional Jakarta Pusat',
        'status_tim': 'aktif',
        'anggota_tim': [
          {
            'id_anggota_tim': 'AGT-001',
            'id_tim': 'TIM-001',
            'id_petugas': 'PTG-001',
            'status_anggota': 'aktif',
            'petugas': {
              'id_petugas': 'PTG-001',
              'nama_petugas': 'Ahmad Ketua',
              'role': 'ketua_tim',
            }
          },
          {
            'id_anggota_tim': 'AGT-002',
            'id_tim': 'TIM-001',
            'id_petugas': 'PTG-002',
            'status_anggota': 'nonaktif',
            'petugas': {
              'id_petugas': 'PTG-002',
              'nama_petugas': 'Doni Driver',
              'role': 'petugas',
            }
          }
        ],
        'created_at': '2026-08-18T10:00:00Z',
        'updated_at': '2026-08-18T10:00:00Z',
      };

      final tim = TimModel.fromJson(json);

      expect(tim.idTim, 'TIM-001');
      expect(tim.namaTim, 'Tim Reaksi Cepat 1');
      expect(tim.note, 'Wilayah Operasional Jakarta Pusat');
      expect(tim.statusTim, 'aktif');
      expect(tim.isAktif, isTrue);
      expect(tim.statusDisplay, 'Aktif');
      expect(tim.anggotaTim.length, 2);
      expect(tim.anggotaAktifCount, 1);
      expect(tim.anggotaTim.first.displayName, 'Ahmad Ketua');
      expect(tim.anggotaTim.first.isKetuaTim, isTrue);
    });

    test('toJson produces valid map', () {
      const tim = TimModel(
        idTim: 'TIM-002',
        namaTim: 'Tim Medis',
        statusTim: 'nonaktif',
      );

      final json = tim.toJson();
      expect(json['id_tim'], 'TIM-002');
      expect(json['nama_tim'], 'Tim Medis');
      expect(json['status_tim'], 'nonaktif');
    });
  });
}
