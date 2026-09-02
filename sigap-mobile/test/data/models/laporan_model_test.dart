import 'package:flutter_test/flutter_test.dart';
import 'package:sigap_mobile/data/models/laporan_model.dart';

void main() {
  group('LaporanModel', () {
    test('fromJson parses all fields correctly', () {
      final json = {
        'status': 'success',
        'message': 'OK',
        'data': {
          'type': 'alarm',
          'total': 3,
          'items': [
            {
              'id_alarm': 'ALM-001',
              'jenis_darurat': 'Banjir',
              'status_alarm': 'diverifikasi',
              'waktu_alarm': '2026-08-28T10:00:00Z',
            },
            {
              'id_alarm': 'ALM-002',
              'jenis_darurat': 'Kebakaran',
              'status_alarm': 'menunggu',
              'waktu_alarm': '2026-08-28T11:00:00Z',
            },
            {
              'id_alarm': 'ALM-003',
              'jenis_darurat': 'Pohon Tumbang',
              'status_alarm': 'selesai',
              'waktu_alarm': '2026-08-28T12:00:00Z',
            },
          ],
        },
      };

      final model = LaporanModel.fromJson(json);

      expect(model.type, 'alarm');
      expect(model.total, 3);
      expect(model.items.length, 3);
      expect(model.items[0]['id_alarm'], 'ALM-001');
      expect(model.items[2]['jenis_darurat'], 'Pohon Tumbang');
    });

    test('fromJson handles empty items', () {
      final json = {
        'data': {
          'type': 'pengguna',
          'total': 0,
          'items': [],
        },
      };
      final model = LaporanModel.fromJson(json);
      expect(model.type, 'pengguna');
      expect(model.total, 0);
      expect(model.items, isEmpty);
      expect(model.isEmpty, true);
    });

    test('isEmpty returns true when items are empty', () {
      final model = LaporanModel(type: 'alarm', total: 0, items: []);
      expect(model.isEmpty, true);
    });

    test('isEmpty returns false when items exist', () {
      final model = LaporanModel(
        type: 'alarm',
        total: 1,
        items: [{'id_alarm': 'X'}],
      );
      expect(model.isEmpty, false);
    });

    test('typeLabel returns correct human-readable label per type', () {
      expect(LaporanModel(type: 'alarm', total: 0, items: []).typeLabel, 'Laporan Alarm');
      expect(LaporanModel(type: 'penugasan', total: 0, items: []).typeLabel, 'Laporan Penugasan');
      expect(LaporanModel(type: 'penanganan', total: 0, items: []).typeLabel, 'Laporan Penanganan');
      expect(LaporanModel(type: 'pengguna', total: 0, items: []).typeLabel, 'Laporan Pengguna');
      expect(LaporanModel(type: 'petugas', total: 0, items: []).typeLabel, 'Laporan Petugas');
      expect(LaporanModel(type: 'unknown', total: 0, items: []).typeLabel, 'Laporan');
    });

    test('toJson serializes correctly', () {
      final model = LaporanModel(
        type: 'penugasan',
        total: 2,
        items: [
          {'id_penugasan': 'TGS-001'},
          {'id_penugasan': 'TGS-002'},
        ],
      );
      final json = model.toJson();
      expect(json['type'], 'penugasan');
      expect(json['total'], 2);
      expect(json['items'].length, 2);
    });

    test('fromJson extracts type from direct root when data missing', () {
      final json = {
        'type': 'alarm',
        'total': 1,
        'items': [{'id_alarm': 'A1'}],
      };
      final model = LaporanModel.fromJson(json);
      expect(model.type, 'alarm');
      expect(model.total, 1);
    });
  });

  group('LaporanFilter', () {
    test('toQueryParameters includes all set fields', () {
      const filter = LaporanFilter(
        type: 'alarm',
        startDate: '2026-01-01',
        endDate: '2026-12-31',
        status: 'diverifikasi',
        jenisDarurat: 'Banjir',
      );
      final params = filter.toQueryParameters();
      expect(params['type'], 'alarm');
      expect(params['start_date'], '2026-01-01');
      expect(params['end_date'], '2026-12-31');
      expect(params['status'], 'diverifikasi');
      expect(params['jenis_darurat'], 'Banjir');
    });

    test('toQueryParameters excludes null or empty fields', () {
      const filter = LaporanFilter(type: 'alarm');
      final params = filter.toQueryParameters();
      expect(params['type'], 'alarm');
      expect(params.containsKey('start_date'), false);
      expect(params.containsKey('end_date'), false);
      expect(params.containsKey('status'), false);
    });

    test('hasActiveFilter returns true if any filter is set', () {
      const empty = LaporanFilter();
      const withDate = LaporanFilter(startDate: '2026-01-01');
      const withStatus = LaporanFilter(status: 'menunggu');
      const withRole = LaporanFilter(role: 'petugas');

      expect(empty.hasActiveFilter, false);
      expect(withDate.hasActiveFilter, true);
      expect(withStatus.hasActiveFilter, true);
      expect(withRole.hasActiveFilter, true);
    });

    test('copyWith preserves unchanged fields', () {
      const original = LaporanFilter(
        type: 'alarm',
        status: 'diverifikasi',
      );
      final updated = original.copyWith(startDate: '2026-01-01');
      expect(updated.type, 'alarm');
      expect(updated.status, 'diverifikasi');
      expect(updated.startDate, '2026-01-01');
    });
  });
}