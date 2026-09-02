import 'package:flutter_test/flutter_test.dart';
import 'package:sigap_mobile/data/models/monitoring_model.dart';

void main() {
  group('MonitoringStatistik', () {
    test('fromJson parses all fields correctly', () {
      final json = {
        'total_alarm': 10,
        'alarm_by_status': {
          'menunggu': 3,
          'diverifikasi': 4,
          'ditolak': 1,
          'selesai': 2,
        },
        'alarm_by_jenis': {
          'Banjir': 5,
          'Kebakaran': 3,
          'Pohon Tumbang': 2,
        },
        'penugasan_aktif': 4,
        'penanganan_aktif': 2,
        'penanganan_selesai': 5,
        'total_korban': 7,
        'total_logistik': 25,
      };

      final stats = MonitoringStatistik.fromJson(json);

      expect(stats.totalAlarm, 10);
      expect(stats.alarmByStatus['menunggu'], 3);
      expect(stats.alarmByStatus['diverifikasi'], 4);
      expect(stats.alarmByJenis['Banjir'], 5);
      expect(stats.penugasanAktif, 4);
      expect(stats.penangananAktif, 2);
      expect(stats.penangananSelesai, 5);
      expect(stats.totalKorban, 7);
      expect(stats.totalLogistik, 25);
    });

    test('fromJson handles null/missing fields with defaults', () {
      final json = <String, dynamic>{};
      final stats = MonitoringStatistik.fromJson(json);

      expect(stats.totalAlarm, 0);
      expect(stats.alarmByStatus, isEmpty);
      expect(stats.alarmByJenis, isEmpty);
      expect(stats.penugasanAktif, 0);
      expect(stats.penangananAktif, 0);
      expect(stats.totalKorban, 0);
    });

    test('fromJson parses string numeric values', () {
      final json = {
        'total_alarm': '15',
        'penugasan_aktif': '8',
        'total_korban': '3',
        'total_logistik': '40',
      };
      final stats = MonitoringStatistik.fromJson(json);

      expect(stats.totalAlarm, 15);
      expect(stats.penugasanAktif, 8);
      expect(stats.totalKorban, 3);
      expect(stats.totalLogistik, 40);
    });

    test('toJson serializes correctly', () {
      final stats = MonitoringStatistik(
        totalAlarm: 5,
        alarmByStatus: {'menunggu': 2, 'selesai': 3},
        alarmByJenis: {'Banjir': 5},
        penugasanAktif: 1,
        penangananAktif: 1,
        penangananSelesai: 1,
        totalKorban: 2,
        totalLogistik: 10,
      );
      final json = stats.toJson();

      expect(json['total_alarm'], 5);
      expect(json['penugasan_aktif'], 1);
      expect(json['alarm_by_status']['menunggu'], 2);
    });
  });

  group('ActiveOperation', () {
    test('fromJson parses basic fields', () {
      final json = {
        'id_alarm': 'ALM-001',
        'jenis_darurat': 'Banjir',
        'waktu_alarm': '2026-08-28T10:00:00Z',
        'latitude': -6.200000,
        'longitude': 106.816666,
        'status_alarm': 'diverifikasi',
      };

      final op = ActiveOperation.fromJson(json);

      expect(op.idAlarm, 'ALM-001');
      expect(op.jenisDarurat, 'Banjir');
      expect(op.waktuAlarm, isNotNull);
      expect(op.latitude, closeTo(-6.2, 0.001));
      expect(op.longitude, closeTo(106.816666, 0.001));
      expect(op.statusAlarm, 'diverifikasi');
    });

    test('statusDisplay returns correct label per status', () {
      ActiveOperation makeOp(String status) => ActiveOperation(
            idAlarm: 'X',
            jenisDarurat: 'Test',
            latitude: 0.0,
            longitude: 0.0,
            statusAlarm: status,
          );

      expect(makeOp('menunggu').statusDisplay, 'Menunggu');
      expect(makeOp('diverifikasi').statusDisplay, 'Diverifikasi');
      expect(makeOp('ditolak').statusDisplay, 'Ditolak');
      expect(makeOp('selesai').statusDisplay, 'Selesai');
      expect(makeOp('unknown').statusDisplay, 'Menunggu');
    });

    test('coordinateDisplay formats with 6 decimal places', () {
      final op = ActiveOperation(
        idAlarm: 'A',
        jenisDarurat: 'B',
        latitude: -6.2,
        longitude: 106.8,
        statusAlarm: 'menunggu',
      );
      expect(op.coordinateDisplay, '-6.200000, 106.800000');
    });

    test('status flag getters', () {
      ActiveOperation makeOp(String status) => ActiveOperation(
            idAlarm: 'X',
            jenisDarurat: 'Test',
            latitude: 0.0,
            longitude: 0.0,
            statusAlarm: status,
          );

      expect(makeOp('menunggu').isPending, true);
      expect(makeOp('diverifikasi').isVerified, true);
      expect(makeOp('ditolak').isRejected, true);
      expect(makeOp('selesai').isCompleted, true);
    });

    test('fromJson parses nested penugasan list', () {
      final json = {
        'id_alarm': 'ALM-001',
        'jenis_darurat': 'Banjir',
        'latitude': 0.0,
        'longitude': 0.0,
        'status_alarm': 'diverifikasi',
        'penugasan': [
          {
            'id_penugasan': 'TGS-001',
            'id_tim': 'TIM-001',
            'nama_tim': 'Tim A',
            'status_penugasan': 'diterima',
            'waktu_penugasan': '2026-08-28T10:05:00Z',
          },
        ],
      };
      final op = ActiveOperation.fromJson(json);
      expect(op.penugasanList, isNotNull);
      expect(op.penugasanList!.length, 1);
      expect(op.penugasanList!.first.namaTim, 'Tim A');
      expect(op.penugasanList!.first.statusPenugasan, 'diterima');
    });

    test('fromJson parses nested penanganan', () {
      final json = {
        'id_alarm': 'ALM-001',
        'jenis_darurat': 'Banjir',
        'latitude': 0.0,
        'longitude': 0.0,
        'status_alarm': 'diverifikasi',
        'penanganan': {
          'id_penanganan': 'PNG-001',
          'status_penanganan': 'di_lokasi',
          'total_korban': 2,
          'total_logistik': 5,
        },
      };
      final op = ActiveOperation.fromJson(json);
      expect(op.penanganan, isNotNull);
      expect(op.penanganan!.idPenanganan, 'PNG-001');
      expect(op.penanganan!.statusPenanganan, 'di_lokasi');
      expect(op.penanganan!.totalKorban, 2);
      expect(op.penanganan!.totalLogistik, 5);
    });
  });

  group('PenangananInfo', () {
    test('statusDisplay returns correct label per status', () {
      PenangananInfo makeInfo(String status) => PenangananInfo(
            idPenanganan: 'X',
            statusPenanganan: status,
            totalKorban: 0,
            totalLogistik: 0,
          );

      expect(makeInfo('menuju_lokasi').statusDisplay, 'Menuju Lokasi');
      expect(makeInfo('di_lokasi').statusDisplay, 'Di Lokasi');
      expect(makeInfo('selesai').statusDisplay, 'Selesai');
    });

    test('status flag getters', () {
      PenangananInfo makeInfo(String status) => PenangananInfo(
            idPenanganan: 'X',
            statusPenanganan: status,
            totalKorban: 0,
            totalLogistik: 0,
          );

      expect(makeInfo('menuju_lokasi').isMenujuLokasi, true);
      expect(makeInfo('di_lokasi').isDiLokasi, true);
      expect(makeInfo('selesai').isSelesai, true);
    });
  });

  group('MonitoringModel', () {
    test('fromJson parses full structure', () {
      final json = {
        'status': 'success',
        'message': 'OK',
        'data': {
          'statistik': {
            'total_alarm': 5,
            'alarm_by_status': {'menunggu': 2, 'selesai': 3},
            'alarm_by_jenis': {'Banjir': 5},
            'penugasan_aktif': 1,
            'penanganan_aktif': 0,
            'penanganan_selesai': 1,
            'total_korban': 0,
            'total_logistik': 0,
          },
          'active_operations': [
            {
              'id_alarm': 'ALM-001',
              'jenis_darurat': 'Banjir',
              'latitude': 0.0,
              'longitude': 0.0,
              'status_alarm': 'menunggu',
            },
          ],
        },
      };

      final model = MonitoringModel.fromJson(json);
      expect(model.statistik.totalAlarm, 5);
      expect(model.activeOperations.length, 1);
      expect(model.activeOperations.first.idAlarm, 'ALM-001');
    });

    test('fromJson handles empty active_operations', () {
      final json = {
        'data': {
          'statistik': {'total_alarm': 0},
          'active_operations': [],
        },
      };
      final model = MonitoringModel.fromJson(json);
      expect(model.activeOperations, isEmpty);
    });
  });
}