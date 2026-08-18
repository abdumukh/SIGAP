import 'package:flutter_test/flutter_test.dart';
import 'package:sigap_mobile/data/models/anggota_tim_model.dart';

void main() {
  group('AnggotaTimModel Tests', () {
    test('parses AnggotaTim JSON with nested Petugas object correctly', () {
      final json = {
        'id_anggota_tim': 'AGT-001',
        'id_tim': 'TIM-001',
        'id_petugas': 'PTG-001',
        'tanggal_masuk': '2026-08-18',
        'status_anggota': 'aktif',
        'petugas': {
          'id_petugas': 'PTG-001',
          'nama_petugas': 'Rizky Ketua',
          'no_hp': '08123456789',
          'email': 'rizky@sigap.go.id',
          'status_petugas': 'aktif',
          'role': 'ketua_tim',
        }
      };

      final member = AnggotaTimModel.fromJson(json);

      expect(member.idAnggotaTim, 'AGT-001');
      expect(member.idTim, 'TIM-001');
      expect(member.idPetugas, 'PTG-001');
      expect(member.namaPetugas, 'Rizky Ketua');
      expect(member.displayName, 'Rizky Ketua');
      expect(member.role, 'ketua_tim');
      expect(member.isKetuaTim, isTrue);
      expect(member.isPetugas, isFalse);
      expect(member.roleDisplay, 'Ketua Tim');
      expect(member.isAktif, isTrue);
      expect(member.statusDisplay, 'Aktif');
    });

    test('fallbacks gracefully when nested petugas is omitted', () {
      final json = {
        'id_anggota_tim': 'AGT-002',
        'id_tim': 'TIM-001',
        'id_petugas': 'PTG-002',
        'status_anggota': 'nonaktif',
      };

      final member = AnggotaTimModel.fromJson(json);

      expect(member.idAnggotaTim, 'AGT-002');
      expect(member.displayName, 'PTG-002');
      expect(member.isNonaktif, isTrue);
      expect(member.statusDisplay, 'Nonaktif');
    });
  });
}
