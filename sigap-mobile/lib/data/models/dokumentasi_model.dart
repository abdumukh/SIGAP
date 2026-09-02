/// Represents a Dokumentasi item from DokumentasiResource.
class DokumentasiModel {
  final String idDokumentasi;
  final String idPenanganan;
  final String idPetugas;
  final String jenisDokumentasi; // 'foto' or 'video'
  final String fileDokumentasi;
  final String? waktuUpload;
  final String? note;
  final String? createdAt;
  final String? updatedAt;

  // Nested penanganan
  final String? penangananId;
  final String? penangananIdAlarm;
  final String? penangananIdPenugasan;
  final String? penangananStatus;

  // Nested petugas
  final String? petugasNama;
  final String? petugasRole;

  const DokumentasiModel({
    required this.idDokumentasi,
    required this.idPenanganan,
    required this.idPetugas,
    required this.jenisDokumentasi,
    required this.fileDokumentasi,
    this.waktuUpload,
    this.note,
    this.createdAt,
    this.updatedAt,
    this.penangananId,
    this.penangananIdAlarm,
    this.penangananIdPenugasan,
    this.penangananStatus,
    this.petugasNama,
    this.petugasRole,
  });

  factory DokumentasiModel.fromJson(Map<String, dynamic> json) {
    final penanganan = json['penanganan'] as Map<String, dynamic>?;
    final petugas = json['petugas'] as Map<String, dynamic>?;

    return DokumentasiModel(
      idDokumentasi: json['id_dokumentasi'] as String,
      idPenanganan: json['id_penanganan'] as String,
      idPetugas: json['id_petugas'] as String,
      jenisDokumentasi: (json['jenis_dokumentasi'] as String?) ?? 'foto',
      fileDokumentasi: json['file_dokumentasi'] as String,
      waktuUpload: json['waktu_upload'] as String?,
      note: json['note'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      // nested penanganan
      penangananId: penanganan?['id_penanganan'] as String?,
      penangananIdAlarm: penanganan?['id_alarm'] as String?,
      penangananIdPenugasan: penanganan?['id_penugasan'] as String?,
      penangananStatus: penanganan?['status_penanganan'] as String?,
      // nested petugas
      petugasNama: petugas?['nama_petugas'] as String?,
      petugasRole: petugas?['role'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_dokumentasi': idDokumentasi,
        'id_penanganan': idPenanganan,
        'id_petugas': idPetugas,
        'jenis_dokumentasi': jenisDokumentasi,
        'file_dokumentasi': fileDokumentasi,
        'waktu_upload': waktuUpload,
        'note': note,
      };

  bool get isFoto => jenisDokumentasi == 'foto';
  bool get isVideo => jenisDokumentasi == 'video';

  String get jenisDisplay => isFoto ? 'Foto' : 'Video';
}
