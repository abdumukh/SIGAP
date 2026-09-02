/// Represents a Penanganan (Emergency Response/Handling) returned by PenangananResource.
class PenangananModel {
  final String idPenanganan;
  final String idAlarm;
  final String idPenugasan;
  final String idPetugas;
  final String? waktuBerangkat;
  final String? waktuTiba;
  final String? waktuSelesai;
  final String statusPenanganan;
  final String? note;
  final String? createdAt;
  final String? updatedAt;

  // Nested alarm
  final String? alarmJenisDarurat;
  final String? alarmWaktu;
  final double? alarmLatitude;
  final double? alarmLongitude;
  final String? alarmStatus;

  // Nested penugasan
  final String? penugasanId;
  final String? penugasanIdAlarm;
  final String? penugasanIdTim;
  final String? penugasanIdKetuaTim;
  final String? penugasanStatus;

  // Nested petugas
  final String? petugasNama;
  final String? petugasRole;

  const PenangananModel({
    required this.idPenanganan,
    required this.idAlarm,
    required this.idPenugasan,
    required this.idPetugas,
    this.waktuBerangkat,
    this.waktuTiba,
    this.waktuSelesai,
    required this.statusPenanganan,
    this.note,
    this.createdAt,
    this.updatedAt,
    this.alarmJenisDarurat,
    this.alarmWaktu,
    this.alarmLatitude,
    this.alarmLongitude,
    this.alarmStatus,
    this.penugasanId,
    this.penugasanIdAlarm,
    this.penugasanIdTim,
    this.penugasanIdKetuaTim,
    this.penugasanStatus,
    this.petugasNama,
    this.petugasRole,
  });

  factory PenangananModel.fromJson(Map<String, dynamic> json) {
    final alarm = json['alarm'] as Map<String, dynamic>?;
    final penugasan = json['penugasan'] as Map<String, dynamic>?;
    final petugas = json['petugas'] as Map<String, dynamic>?;

    return PenangananModel(
      idPenanganan: json['id_penanganan'] as String,
      idAlarm: json['id_alarm'] as String,
      idPenugasan: json['id_penugasan'] as String,
      idPetugas: json['id_petugas'] as String,
      waktuBerangkat: json['waktu_berangkat'] as String?,
      waktuTiba: json['waktu_tiba'] as String?,
      waktuSelesai: json['waktu_selesai'] as String?,
      statusPenanganan:
          (json['status_penanganan'] as String?) ?? 'menuju_lokasi',
      note: json['note'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      // nested alarm
      alarmJenisDarurat: alarm?['jenis_darurat'] as String?,
      alarmWaktu: alarm?['waktu_alarm'] as String?,
      alarmLatitude: (alarm?['latitude'] as num?)?.toDouble(),
      alarmLongitude: (alarm?['longitude'] as num?)?.toDouble(),
      alarmStatus: alarm?['status_alarm'] as String?,
      // nested penugasan
      penugasanId: penugasan?['id_penugasan'] as String?,
      penugasanIdAlarm: penugasan?['id_alarm'] as String?,
      penugasanIdTim: penugasan?['id_tim'] as String?,
      penugasanIdKetuaTim: penugasan?['id_ketua_tim'] as String?,
      penugasanStatus: penugasan?['status_penugasan'] as String?,
      // nested petugas
      petugasNama: petugas?['nama_petugas'] as String?,
      petugasRole: petugas?['role'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_penanganan': idPenanganan,
        'id_alarm': idAlarm,
        'id_penugasan': idPenugasan,
        'id_petugas': idPetugas,
        'waktu_berangkat': waktuBerangkat,
        'waktu_tiba': waktuTiba,
        'waktu_selesai': waktuSelesai,
        'status_penanganan': statusPenanganan,
        'note': note,
      };

  // --- Status Helpers ---
  bool get isMenujuLokasi => statusPenanganan == 'menuju_lokasi';
  bool get isDiLokasi => statusPenanganan == 'di_lokasi';
  bool get isSelesai => statusPenanganan == 'selesai';

  String get statusDisplay {
    switch (statusPenanganan) {
      case 'menuju_lokasi':
        return 'Menuju Lokasi';
      case 'di_lokasi':
        return 'Tiba di Lokasi';
      case 'selesai':
        return 'Penanganan Selesai';
      default:
        return statusPenanganan;
    }
  }

  String get statusLabel => statusDisplay;

  String? get nextValidStatus {
    switch (statusPenanganan) {
      case 'menuju_lokasi':
        return 'di_lokasi';
      case 'di_lokasi':
        return 'selesai';
      default:
        return null;
    }
  }

  String? get nextActionLabel {
    switch (statusPenanganan) {
      case 'menuju_lokasi':
        return 'SUDAH TIBA DI LOKASI';
      case 'di_lokasi':
        return 'SELESAIKAN PENANGANAN';
      default:
        return null;
    }
  }
}
