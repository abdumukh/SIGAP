import 'package:flutter_test/flutter_test.dart';
import 'package:sigap_mobile/data/models/korban_model.dart';

void main() {
  group('KorbanModel Tests', () {
    test('parses Korban JSON with nested penanganan relation', () {
      final json = {
        'id_korban': 'KRB-001',
        'id_penanganan': 'PNG-001',
        'nama_korban': 'Budi Santoso',
        'jenis_kelamin': 'L',
        'usia': 35,
        'kondisi': 'Luka Ringan',
        'status_penanganan': 'Dievakuasi ke RS',
        'note': 'Perlu perawatan medis',
        'created_at': '2026-08-28T10:30:00Z',
        'updated_at': '2026-08-28T10:30:00Z',
        'penanganan': {
          'id_penanganan': 'PNG-001',
          'id_alarm': 'ALM-001',
          'id_penugasan': 'TGS-001',
          'status_penanganan': 'di_lokasi',
        },
      };

      final model = KorbanModel.fromJson(json);

      expect(model.idKorban, 'KRB-001');
      expect(model.idPenanganan, 'PNG-001');
      expect(model.namaKorban, 'Budi Santoso');
      expect(model.jenisKelamin, 'L');
      expect(model.usia, 35);
      expect(model.kondisi, 'Luka Ringan');
      expect(model.statusPenanganan, 'Dievakuasi ke RS');
      expect(model.note, 'Perlu perawatan medis');
      expect(model.createdAt, '2026-08-28T10:30:00Z');

      // Nested
      expect(model.penangananId, 'PNG-001');
      expect(model.penangananStatus, 'di_lokasi');
    });

    test('parses Korban JSON without nested penanganan', () {
      final json = {
        'id_korban': 'KRB-002',
        'id_penanganan': 'PNG-002',
        'nama_korban': 'Siti Rahma',
        'jenis_kelamin': 'P',
        'usia': 28,
        'kondisi': 'Selamat',
        'status_penanganan': 'Ditampung di Posko',
      };

      final model = KorbanModel.fromJson(json);

      expect(model.idKorban, 'KRB-002');
      expect(model.namaKorban, 'Siti Rahma');
      expect(model.jenisKelamin, 'P');
      expect(model.usia, 28);
      expect(model.note, isNull);
      expect(model.penangananId, isNull);
      expect(model.penangananStatus, isNull);
    });

    test('toJson serializes correctly', () {
      const model = KorbanModel(
        idKorban: 'KRB-003',
        idPenanganan: 'PNG-001',
        namaKorban: 'Ahmad',
        jenisKelamin: 'L',
        usia: 40,
        kondisi: 'Kritis',
        statusPenanganan: 'Di rawat ICU',
        note: 'Kondisi darurat',
      );

      final json = model.toJson();

      expect(json['id_penanganan'], 'PNG-001');
      expect(json['nama_korban'], 'Ahmad');
      expect(json['jenis_kelamin'], 'L');
      expect(json['usia'], 40);
      expect(json['kondisi'], 'Kritis');
      expect(json['status_penanganan'], 'Di rawat ICU');
      expect(json['note'], 'Kondisi darurat');
    });

    test('helper getters return correct display strings', () {
      const male = KorbanModel(
        idKorban: 'KRB-001',
        idPenanganan: 'PNG-001',
        namaKorban: 'Budi',
        jenisKelamin: 'L',
        usia: 30,
        kondisi: 'Baik',
        statusPenanganan: 'Selesai',
      );

      const female = KorbanModel(
        idKorban: 'KRB-002',
        idPenanganan: 'PNG-001',
        namaKorban: 'Siti',
        jenisKelamin: 'P',
        usia: 25,
        kondisi: 'Baik',
        statusPenanganan: 'Selesai',
      );

      expect(male.jenisKelaminDisplay, 'Laki-laki');
      expect(male.usiaDisplay, '30 Tahun');
      expect(female.jenisKelaminDisplay, 'Perempuan');
      expect(female.usiaDisplay, '25 Tahun');
    });
  });
}