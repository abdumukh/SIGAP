/// Represents a Korban (Victim) returned by KorbanResource.
class KorbanModel {
  final String idKorban;
  final String idPenanganan;
  final String namaKorban;
  final String jenisKelamin;
  final int usia;
  final String kondisi;
  final String statusPenanganan;
  final String? note;
  final String? createdAt;
  final String? updatedAt;

  // Nested penanganan
  final String? penangananId;
  final String? penangananIdAlarm;
  final String? penangananIdPenugasan;
  final String? penangananStatus;

  const KorbanModel({
    required this.idKorban,
    required this.idPenanganan,
    required this.namaKorban,
    required this.jenisKelamin,
    required this.usia,
    required this.kondisi,
    required this.statusPenanganan,
    this.note,
    this.createdAt,
    this.updatedAt,
    this.penangananId,
    this.penangananIdAlarm,
    this.penangananIdPenugasan,
    this.penangananStatus,
  });

  factory KorbanModel.fromJson(Map<String, dynamic> json) {
    final penanganan = json['penanganan'] as Map<String, dynamic>?;

    return KorbanModel(
      idKorban: json['id_korban'] as String,
      idPenanganan: json['id_penanganan'] as String,
      namaKorban: json['nama_korban'] as String,
      jenisKelamin: json['jenis_kelamin'] as String,
      usia: json['usia'] as int,
      kondisi: json['kondisi'] as String,
      statusPenanganan: json['status_penanganan'] as String,
      note: json['note'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      penangananId: penanganan?['id_penanganan'] as String?,
      penangananIdAlarm: penanganan?['id_alarm'] as String?,
      penangananIdPenugasan: penanganan?['id_penugasan'] as String?,
      penangananStatus: penanganan?['status_penanganan'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_penanganan': idPenanganan,
        'nama_korban': namaKorban,
        'jenis_kelamin': jenisKelamin,
        'usia': usia,
        'kondisi': kondisi,
        'status_penanganan': statusPenanganan,
        'note': note,
      };

  String get jenisKelaminDisplay => jenisKelamin == 'L' ? 'Laki-laki' : 'Perempuan';

  String get usiaDisplay => '$usia Tahun';
}