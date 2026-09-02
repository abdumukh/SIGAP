/// Represents a Penugasan returned by PenugasanResource.
class PenugasanModel {
  final String idPenugasan;
  final String idAlarm;
  final String idTim;
  final String? idPetugasArmada;
  final String? idArmada;
  final String idKetuaTim;
  final String? waktuPenugasan;
  final String statusPenugasan;
  final String? note;
  final String? createdAt;
  final String? updatedAt;

  // Nested: alarm
  final String? alarmJenisDarurat;
  final String? alarmWaktu;
  final double? alarmLatitude;
  final double? alarmLongitude;
  final String? alarmStatus;

  // Nested: tim
  final String? timNama;
  final String? timStatus;

  // Nested: ketua_tim
  final String? ketuaTimNama;
  final String? ketuaTimRole;

  // Nested: petugas_armada
  final String? petugasArmadaNama;
  final String? petugasArmadaRole;

  // Nested: armada
  final String? armadaNama;
  final String? armadaJenis;
  final String? armadaNomor;
  final String? armadaStatus;

  const PenugasanModel({
    required this.idPenugasan,
    required this.idAlarm,
    required this.idTim,
    this.idPetugasArmada,
    this.idArmada,
    required this.idKetuaTim,
    this.waktuPenugasan,
    required this.statusPenugasan,
    this.note,
    this.createdAt,
    this.updatedAt,
    this.alarmJenisDarurat,
    this.alarmWaktu,
    this.alarmLatitude,
    this.alarmLongitude,
    this.alarmStatus,
    this.timNama,
    this.timStatus,
    this.ketuaTimNama,
    this.ketuaTimRole,
    this.petugasArmadaNama,
    this.petugasArmadaRole,
    this.armadaNama,
    this.armadaJenis,
    this.armadaNomor,
    this.armadaStatus,
  });

  factory PenugasanModel.fromJson(Map<String, dynamic> json) {
    final alarm = json['alarm'] as Map<String, dynamic>?;
    final tim = json['tim'] as Map<String, dynamic>?;
    final ketuaTim = json['ketua_tim'] as Map<String, dynamic>?;
    final petugasArmada = json['petugas_armada'] as Map<String, dynamic>?;
    final armada = json['armada'] as Map<String, dynamic>?;

    return PenugasanModel(
      idPenugasan: json['id_penugasan'] as String,
      idAlarm: json['id_alarm'] as String,
      idTim: json['id_tim'] as String,
      idPetugasArmada: json['id_petugas_armada'] as String?,
      idArmada: json['id_armada'] as String?,
      idKetuaTim: json['id_ketua_tim'] as String,
      waktuPenugasan: json['waktu_penugasan'] as String?,
      statusPenugasan: (json['status_penugasan'] as String?) ?? 'menunggu',
      note: json['note'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      // nested alarm
      alarmJenisDarurat: alarm?['jenis_darurat'] as String?,
      alarmWaktu: alarm?['waktu_alarm'] as String?,
      alarmLatitude: (alarm?['latitude'] as num?)?.toDouble(),
      alarmLongitude: (alarm?['longitude'] as num?)?.toDouble(),
      alarmStatus: alarm?['status_alarm'] as String?,
      // nested tim
      timNama: tim?['nama_tim'] as String?,
      timStatus: tim?['status_tim'] as String?,
      // nested ketua_tim
      ketuaTimNama: ketuaTim?['nama_petugas'] as String?,
      ketuaTimRole: ketuaTim?['role'] as String?,
      // nested petugas_armada
      petugasArmadaNama: petugasArmada?['nama_petugas'] as String?,
      petugasArmadaRole: petugasArmada?['role'] as String?,
      // nested armada
      armadaNama: armada?['nama_armada'] as String?,
      armadaJenis: armada?['jenis_armada'] as String?,
      armadaNomor: armada?['nomor_kendaraan'] as String?,
      armadaStatus: armada?['status_armada'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_penugasan': idPenugasan,
        'id_alarm': idAlarm,
        'id_tim': idTim,
        'id_petugas_armada': idPetugasArmada,
        'id_armada': idArmada,
        'id_ketua_tim': idKetuaTim,
        'waktu_penugasan': waktuPenugasan,
        'status_penugasan': statusPenugasan,
        'note': note,
      };

  // --- Status helpers ---
  bool get isMenunggu => statusPenugasan == 'menunggu';
  bool get isDiterima => statusPenugasan == 'diterima';
  bool get isBerangkat => statusPenugasan == 'berangkat';
  bool get isSelesai => statusPenugasan == 'selesai';
  bool get isDitolak => statusPenugasan == 'ditolak';

  bool get hasArmada => idArmada != null && idArmada!.isNotEmpty;

  String get statusDisplay {
    switch (statusPenugasan) {
      case 'menunggu':
        return 'Menunggu';
      case 'diterima':
        return 'Diterima';
      case 'berangkat':
        return 'Dalam Proses';
      case 'selesai':
        return 'Selesai';
      case 'ditolak':
        return 'Ditolak';
      default:
        return statusPenugasan;
    }
  }
}
