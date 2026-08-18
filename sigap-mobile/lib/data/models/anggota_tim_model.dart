/// Represents an AnggotaTim (Team Member) from AnggotaTimResource.
class AnggotaTimModel {
  final String idAnggotaTim;
  final String idTim;
  final String idPetugas;
  final String? tanggalMasuk;
  final String statusAnggota;
  // Nested petugas object (whenLoaded)
  final String? namaPetugas;
  final String? noHp;
  final String? email;
  final String? alamat;
  final String? statusPetugas;
  final String? role;
  final String? createdAt;
  final String? updatedAt;

  const AnggotaTimModel({
    required this.idAnggotaTim,
    required this.idTim,
    required this.idPetugas,
    this.tanggalMasuk,
    required this.statusAnggota,
    this.namaPetugas,
    this.noHp,
    this.email,
    this.alamat,
    this.statusPetugas,
    this.role,
    this.createdAt,
    this.updatedAt,
  });

  factory AnggotaTimModel.fromJson(Map<String, dynamic> json) {
    final petugas = json['petugas'] as Map<String, dynamic>?;

    return AnggotaTimModel(
      idAnggotaTim: json['id_anggota_tim'] as String,
      idTim: json['id_tim'] as String,
      idPetugas: json['id_petugas'] as String,
      tanggalMasuk: json['tanggal_masuk'] as String?,
      statusAnggota: (json['status_anggota'] as String?) ?? 'aktif',
      namaPetugas: petugas?['nama_petugas'] as String?,
      noHp: petugas?['no_hp'] as String?,
      email: petugas?['email'] as String?,
      alamat: petugas?['alamat'] as String?,
      statusPetugas: petugas?['status_petugas'] as String?,
      role: petugas?['role'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_anggota_tim': idAnggotaTim,
        'id_tim': idTim,
        'id_petugas': idPetugas,
        'tanggal_masuk': tanggalMasuk,
        'status_anggota': statusAnggota,
      };

  // --- Status helpers ---
  bool get isAktif => statusAnggota == 'aktif';
  bool get isNonaktif => statusAnggota == 'nonaktif';
  bool get isKetuaTim => role == 'ketua_tim';
  bool get isPetugas => role == 'petugas';

  String get statusDisplay => isAktif ? 'Aktif' : 'Nonaktif';
  String get roleDisplay =>
      isKetuaTim ? 'Ketua Tim' : (isPetugas ? 'Petugas' : role ?? '-');

  String get displayName => namaPetugas ?? idPetugas;
}
