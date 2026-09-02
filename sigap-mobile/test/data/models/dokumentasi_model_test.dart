import 'package:flutter_test/flutter_test.dart';
import 'package:sigap_mobile/data/models/dokumentasi_model.dart';

void main() {
  group('DokumentasiModel Tests', () {
    test('parses Dokumentasi JSON with nested relations', () {
      final json = {
        'id_dokumentasi': 'DOC-001',
        'id_penanganan': 'PNG-001',
        'id_petugas': 'PTG-001',
        'jenis_dokumentasi': 'foto',
        'file_dokumentasi': 'dokumentasi/foto_lokasi.jpg',
        'waktu_upload': '2026-08-20T10:30:00Z',
        'note': 'Foto armada damkar di depan lokasi kebakaran.',
        'created_at': '2026-08-20T10:30:00Z',
        'updated_at': '2026-08-20T10:30:00Z',
        'penanganan': {
          'id_penanganan': 'PNG-001',
          'id_alarm': 'ALM-001',
          'id_penugasan': 'TGS-001',
          'status_penanganan': 'di_lokasi',
        },
        'petugas': {
          'id_petugas': 'PTG-001',
          'nama_petugas': 'Budi Responder',
          'role': 'petugas',
        },
      };

      final model = DokumentasiModel.fromJson(json);

      expect(model.idDokumentasi, 'DOC-001');
      expect(model.idPenanganan, 'PNG-001');
      expect(model.idPetugas, 'PTG-001');
      expect(model.jenisDokumentasi, 'foto');
      expect(model.fileDokumentasi, 'dokumentasi/foto_lokasi.jpg');
      expect(model.waktuUpload, '2026-08-20T10:30:00Z');
      expect(model.note, 'Foto armada damkar di depan lokasi kebakaran.');

      // Nested
      expect(model.penangananId, 'PNG-001');
      expect(model.penangananStatus, 'di_lokasi');
      expect(model.petugasNama, 'Budi Responder');
      expect(model.petugasRole, 'petugas');

      // Helpers
      expect(model.isFoto, isTrue);
      expect(model.isVideo, isFalse);
      expect(model.jenisDisplay, 'Foto');
    });

    test('verifies video documentation helpers', () {
      const model = DokumentasiModel(
        idDokumentasi: 'DOC-002',
        idPenanganan: 'PNG-001',
        idPetugas: 'PTG-001',
        jenisDokumentasi: 'video',
        fileDokumentasi: 'dokumentasi/video_evakuasi.mp4',
      );

      expect(model.isFoto, isFalse);
      expect(model.isVideo, isTrue);
      expect(model.jenisDisplay, 'Video');
    });

    test('toJson serializes correctly', () {
      const model = DokumentasiModel(
        idDokumentasi: 'DOC-003',
        idPenanganan: 'PNG-002',
        idPetugas: 'PTG-002',
        jenisDokumentasi: 'foto',
        fileDokumentasi: 'dokumentasi/bukti.jpg',
        waktuUpload: '2026-08-20T11:00:00Z',
        note: 'Dokumentasi selesai',
      );

      final json = model.toJson();

      expect(json['id_dokumentasi'], 'DOC-003');
      expect(json['id_penanganan'], 'PNG-002');
      expect(json['id_petugas'], 'PTG-002');
      expect(json['jenis_dokumentasi'], 'foto');
      expect(json['file_dokumentasi'], 'dokumentasi/bukti.jpg');
      expect(json['note'], 'Dokumentasi selesai');
    });
  });
}
