import 'package:flutter_test/flutter_test.dart';
import 'package:sigap_mobile/data/models/logistik_model.dart';

void main() {
  group('LogistikModel Tests', () {
    test('parses Logistik JSON with nested penanganan relation', () {
      final json = {
        'id_logistik': 'LOG-001',
        'id_penanganan': 'PNG-001',
        'nama_logistik': 'Selang Pemadam',
        'jumlah': 4,
        'satuan': 'Unit',
        'kondisi': 'Baik',
        'note': 'Untuk memadamkan api',
        'created_at': '2026-08-28T10:30:00Z',
        'updated_at': '2026-08-28T10:30:00Z',
        'penanganan': {
          'id_penanganan': 'PNG-001',
          'id_alarm': 'ALM-001',
          'id_penugasan': 'TGS-001',
          'status_penanganan': 'di_lokasi',
        },
      };

      final model = LogistikModel.fromJson(json);

      expect(model.idLogistik, 'LOG-001');
      expect(model.idPenanganan, 'PNG-001');
      expect(model.namaLogistik, 'Selang Pemadam');
      expect(model.jumlah, 4);
      expect(model.satuan, 'Unit');
      expect(model.kondisi, 'Baik');
      expect(model.note, 'Untuk memadamkan api');
      expect(model.createdAt, '2026-08-28T10:30:00Z');

      // Nested
      expect(model.penangananId, 'PNG-001');
      expect(model.penangananStatus, 'di_lokasi');
    });

    test('parses Logistik JSON without nested penanganan', () {
      final json = {
        'id_logistik': 'LOG-002',
        'id_penanganan': 'PNG-002',
        'nama_logistik': 'Masker Gas',
        'jumlah': 10,
        'satuan': 'Pcs',
        'kondisi': 'Baik',
      };

      final model = LogistikModel.fromJson(json);

      expect(model.idLogistik, 'LOG-002');
      expect(model.namaLogistik, 'Masker Gas');
      expect(model.jumlah, 10);
      expect(model.satuan, 'Pcs');
      expect(model.note, isNull);
      expect(model.penangananId, isNull);
    });

    test('toJson serializes correctly', () {
      const model = LogistikModel(
        idLogistik: 'LOG-003',
        idPenanganan: 'PNG-001',
        namaLogistik: 'Tangki Air',
        jumlah: 2,
        satuan: 'Unit',
        kondisi: 'Rusak',
        note: 'Perlu perbaikan',
      );

      final json = model.toJson();

      expect(json['id_penanganan'], 'PNG-001');
      expect(json['nama_logistik'], 'Tangki Air');
      expect(json['jumlah'], 2);
      expect(json['satuan'], 'Unit');
      expect(json['kondisi'], 'Rusak');
      expect(json['note'], 'Perlu perbaikan');
    });

    test('jumlahDisplay combines jumlah and satuan', () {
      const model = LogistikModel(
        idLogistik: 'LOG-001',
        idPenanganan: 'PNG-001',
        namaLogistik: 'Obat',
        jumlah: 50,
        satuan: 'Tablet',
        kondisi: 'Baik',
      );

      expect(model.jumlahDisplay, '50 Tablet');
    });
  });
}