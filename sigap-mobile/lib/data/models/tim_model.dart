import 'anggota_tim_model.dart';

/// Represents a Tim (Team) returned by GET /api/tim and GET /api/tim/{id}.
class TimModel {
  final String idTim;
  final String namaTim;
  final String? note;
  final String statusTim;
  final List<AnggotaTimModel> anggotaTim;
  final String? createdAt;
  final String? updatedAt;

  const TimModel({
    required this.idTim,
    required this.namaTim,
    this.note,
    required this.statusTim,
    this.anggotaTim = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory TimModel.fromJson(Map<String, dynamic> json) {
    final anggotaRaw = json['anggota_tim'];
    final List<AnggotaTimModel> anggotaList = anggotaRaw is List
        ? anggotaRaw
            .map((a) => AnggotaTimModel.fromJson(a as Map<String, dynamic>))
            .toList()
        : [];

    return TimModel(
      idTim: json['id_tim'] as String,
      namaTim: json['nama_tim'] as String,
      note: json['note'] as String?,
      statusTim: (json['status_tim'] as String?) ?? 'aktif',
      anggotaTim: anggotaList,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_tim': idTim,
        'nama_tim': namaTim,
        'note': note,
        'status_tim': statusTim,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  // --- Status helpers ---
  bool get isAktif => statusTim == 'aktif';
  bool get isNonaktif => statusTim == 'nonaktif';

  String get statusDisplay => isAktif ? 'Aktif' : 'Nonaktif';

  int get anggotaAktifCount =>
      anggotaTim.where((a) => a.isAktif).length;
}
