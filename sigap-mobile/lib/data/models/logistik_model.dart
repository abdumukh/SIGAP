/// Represents a Logistik returned by LogistikResource.
class LogistikModel {
  final String idLogistik;
  final String idPenanganan;
  final String namaLogistik;
  final int jumlah;
  final String satuan;
  final String kondisi;
  final String? note;
  final String? createdAt;
  final String? updatedAt;

  // Nested penanganan
  final String? penangananId;
  final String? penangananIdAlarm;
  final String? penangananIdPenugasan;
  final String? penangananStatus;

  const LogistikModel({
    required this.idLogistik,
    required this.idPenanganan,
    required this.namaLogistik,
    required this.jumlah,
    required this.satuan,
    required this.kondisi,
    this.note,
    this.createdAt,
    this.updatedAt,
    this.penangananId,
    this.penangananIdAlarm,
    this.penangananIdPenugasan,
    this.penangananStatus,
  });

  factory LogistikModel.fromJson(Map<String, dynamic> json) {
    final penanganan = json['penanganan'] as Map<String, dynamic>?;

    return LogistikModel(
      idLogistik: json['id_logistik'] as String,
      idPenanganan: json['id_penanganan'] as String,
      namaLogistik: json['nama_logistik'] as String,
      jumlah: json['jumlah'] as int,
      satuan: json['satuan'] as String,
      kondisi: json['kondisi'] as String,
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
        'nama_logistik': namaLogistik,
        'jumlah': jumlah,
        'satuan': satuan,
        'kondisi': kondisi,
        'note': note,
      };

  String get jumlahDisplay => '$jumlah $satuan';
}