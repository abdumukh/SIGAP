import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Summary statistics from monitoring endpoint.
class MonitoringStatistik {
  final int totalAlarm;
  final Map<String, int> alarmByStatus;
  final Map<String, int> alarmByJenis;
  final int penugasanAktif;
  final int penangananAktif;
  final int penangananSelesai;
  final int totalKorban;
  final int totalLogistik;

  const MonitoringStatistik({
    required this.totalAlarm,
    required this.alarmByStatus,
    required this.alarmByJenis,
    required this.penugasanAktif,
    required this.penangananAktif,
    required this.penangananSelesai,
    required this.totalKorban,
    required this.totalLogistik,
  });

  factory MonitoringStatistik.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    Map<String, int> parseMap(Map<String, dynamic>? map) {
      if (map == null) return {};
      return map.map((k, v) => MapEntry(k, parseInt(v)));
    }

    return MonitoringStatistik(
      totalAlarm: parseInt(json['total_alarm']),
      alarmByStatus: parseMap(json['alarm_by_status'] as Map<String, dynamic>?),
      alarmByJenis: parseMap(json['alarm_by_jenis'] as Map<String, dynamic>?),
      penugasanAktif: parseInt(json['penugasan_aktif']),
      penangananAktif: parseInt(json['penanganan_aktif']),
      penangananSelesai: parseInt(json['penanganan_selesai']),
      totalKorban: parseInt(json['total_korban']),
      totalLogistik: parseInt(json['total_logistik']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_alarm': totalAlarm,
      'alarm_by_status': alarmByStatus,
      'alarm_by_jenis': alarmByJenis,
      'penugasan_aktif': penugasanAktif,
      'penanganan_aktif': penangananAktif,
      'penanganan_selesai': penangananSelesai,
      'total_korban': totalKorban,
      'total_logistik': totalLogistik,
    };
  }
}

/// Active operation item from monitoring response.
class ActiveOperation {
  final String idAlarm;
  final String jenisDarurat;
  final DateTime? waktuAlarm;
  final double latitude;
  final double longitude;
  final String? cuaca;
  final String? laluLintas;
  final String statusAlarm;
  final Map<String, dynamic>? pelapor;
  final List<PenugasanInfo>? penugasanList;
  final PenangananInfo? penanganan;

  const ActiveOperation({
    required this.idAlarm,
    required this.jenisDarurat,
    this.waktuAlarm,
    required this.latitude,
    required this.longitude,
    this.cuaca,
    this.laluLintas,
    required this.statusAlarm,
    this.pelapor,
    this.penugasanList,
    this.penanganan,
  });

  factory ActiveOperation.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return null;
      }
    }

    double parseDouble(dynamic value, double fallback) {
      if (value == null) return fallback;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? fallback;
    }

    List<PenugasanInfo>? parsedPenugasan;
    if (json['penugasan'] is List) {
      parsedPenugasan = (json['penugasan'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => PenugasanInfo.fromJson(item))
          .toList();
    }

    PenangananInfo? parsedPenanganan;
    if (json['penanganan'] is Map<String, dynamic>) {
      parsedPenanganan = PenangananInfo.fromJson(json['penanganan'] as Map<String, dynamic>);
    }

    return ActiveOperation(
      idAlarm: json['id_alarm']?.toString() ?? '',
      jenisDarurat: json['jenis_darurat']?.toString() ?? 'Darurat',
      waktuAlarm: parseDate(json['waktu_alarm']),
      latitude: parseDouble(json['latitude'], 0.0),
      longitude: parseDouble(json['longitude'], 0.0),
      cuaca: json['cuaca']?.toString(),
      laluLintas: json['lalu_lintas']?.toString(),
      statusAlarm: json['status_alarm']?.toString() ?? 'menunggu',
      pelapor: json['pelapor'] is Map<String, dynamic>
          ? json['pelapor'] as Map<String, dynamic>
          : null,
      penugasanList: parsedPenugasan,
      penanganan: parsedPenanganan,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_alarm': idAlarm,
      'jenis_darurat': jenisDarurat,
      'waktu_alarm': waktuAlarm?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'cuaca': cuaca,
      'lalu_lintas': laluLintas,
      'status_alarm': statusAlarm,
      if (pelapor != null) 'pelapor': pelapor,
      if (penugasanList != null) 'penugasan': penugasanList!.map((e) => e.toJson()).toList(),
      if (penanganan != null) 'penanganan': penanganan!.toJson(),
    };
  }

  bool get isPending => statusAlarm == 'menunggu';
  bool get isVerified => statusAlarm == 'diverifikasi';
  bool get isRejected => statusAlarm == 'ditolak';
  bool get isCompleted => statusAlarm == 'selesai';

  String get statusDisplay {
    switch (statusAlarm.toLowerCase()) {
      case 'diverifikasi':
        return 'Diverifikasi';
      case 'ditolak':
        return 'Ditolak';
      case 'selesai':
        return 'Selesai';
      case 'menunggu':
      default:
        return 'Menunggu';
    }
  }

  Color get statusColor {
    switch (statusAlarm.toLowerCase()) {
      case 'diverifikasi':
        return AppColors.info;
      case 'ditolak':
        return AppColors.error;
      case 'selesai':
        return AppColors.success;
      case 'menunggu':
      default:
        return AppColors.warning;
    }
  }

  String get coordinateDisplay =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
}

/// Penugasan info nested in active operation.
class PenugasanInfo {
  final String idPenugasan;
  final String idTim;
  final String? namaTim;
  final String statusPenugasan;
  final DateTime? waktuPenugasan;
  final Map<String, dynamic>? ketuaTim;
  final Map<String, dynamic>? petugasArmada;
  final Map<String, dynamic>? armada;
  final List<AnggotaTimInfo>? anggotaTim;

  const PenugasanInfo({
    required this.idPenugasan,
    required this.idTim,
    this.namaTim,
    required this.statusPenugasan,
    this.waktuPenugasan,
    this.ketuaTim,
    this.petugasArmada,
    this.armada,
    this.anggotaTim,
  });

  factory PenugasanInfo.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return null;
      }
    }

    List<AnggotaTimInfo>? parsedAnggota;
    if (json['anggota_tim'] is List) {
      parsedAnggota = (json['anggota_tim'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => AnggotaTimInfo.fromJson(item))
          .toList();
    }

    return PenugasanInfo(
      idPenugasan: json['id_penugasan']?.toString() ?? '',
      idTim: json['id_tim']?.toString() ?? '',
      namaTim: json['nama_tim']?.toString(),
      statusPenugasan: json['status_penugasan']?.toString() ?? 'menunggu',
      waktuPenugasan: parseDate(json['waktu_penugasan']),
      ketuaTim: json['ketua_tim'] is Map<String, dynamic>
          ? json['ketua_tim'] as Map<String, dynamic>
          : null,
      petugasArmada: json['petugas_armada'] is Map<String, dynamic>
          ? json['petugas_armada'] as Map<String, dynamic>
          : null,
      armada: json['armada'] is Map<String, dynamic>
          ? json['armada'] as Map<String, dynamic>
          : null,
      anggotaTim: parsedAnggota,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_penugasan': idPenugasan,
      'id_tim': idTim,
      'nama_tim': namaTim,
      'status_penugasan': statusPenugasan,
      'waktu_penugasan': waktuPenugasan?.toIso8601String(),
      if (ketuaTim != null) 'ketua_tim': ketuaTim,
      if (petugasArmada != null) 'petugas_armada': petugasArmada,
      if (armada != null) 'armada': armada,
      if (anggotaTim != null) 'anggota_tim': anggotaTim!.map((e) => e.toJson()).toList(),
    };
  }
}

/// Anggota tim info nested in penugasan.
class AnggotaTimInfo {
  final String idPetugas;
  final String? namaPetugas;
  final String? roleTim;

  const AnggotaTimInfo({
    required this.idPetugas,
    this.namaPetugas,
    this.roleTim,
  });

  factory AnggotaTimInfo.fromJson(Map<String, dynamic> json) {
    return AnggotaTimInfo(
      idPetugas: json['id_petugas']?.toString() ?? '',
      namaPetugas: json['nama_petugas']?.toString(),
      roleTim: json['role_tim']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_petugas': idPetugas,
      'nama_petugas': namaPetugas,
      'role_tim': roleTim,
    };
  }
}

/// Penanganan info nested in active operation.
class PenangananInfo {
  final String idPenanganan;
  final String statusPenanganan;
  final DateTime? waktuBerangkat;
  final DateTime? waktuTiba;
  final DateTime? waktuSelesai;
  final String? note;
  final Map<String, dynamic>? petugasHandler;
  final List<DokumentasiInfo>? dokumentasi;
  final int totalKorban;
  final int totalLogistik;

  const PenangananInfo({
    required this.idPenanganan,
    required this.statusPenanganan,
    this.waktuBerangkat,
    this.waktuTiba,
    this.waktuSelesai,
    this.note,
    this.petugasHandler,
    this.dokumentasi,
    required this.totalKorban,
    required this.totalLogistik,
  });

  factory PenangananInfo.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return null;
      }
    }

    List<DokumentasiInfo>? parsedDokumentasi;
    if (json['dokumentasi'] is List) {
      parsedDokumentasi = (json['dokumentasi'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => DokumentasiInfo.fromJson(item))
          .toList();
    }

    return PenangananInfo(
      idPenanganan: json['id_penanganan']?.toString() ?? '',
      statusPenanganan: json['status_penanganan']?.toString() ?? 'menuju_lokasi',
      waktuBerangkat: parseDate(json['waktu_berangkat']),
      waktuTiba: parseDate(json['waktu_tiba']),
      waktuSelesai: parseDate(json['waktu_selesai']),
      note: json['note']?.toString(),
      petugasHandler: json['petugas_handler'] is Map<String, dynamic>
          ? json['petugas_handler'] as Map<String, dynamic>
          : null,
      dokumentasi: parsedDokumentasi,
      totalKorban: json['total_korban'] as int? ?? 0,
      totalLogistik: json['total_logistik'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_penanganan': idPenanganan,
      'status_penanganan': statusPenanganan,
      'waktu_berangkat': waktuBerangkat?.toIso8601String(),
      'waktu_tiba': waktuTiba?.toIso8601String(),
      'waktu_selesai': waktuSelesai?.toIso8601String(),
      'note': note,
      if (petugasHandler != null) 'petugas_handler': petugasHandler,
      if (dokumentasi != null) 'dokumentasi': dokumentasi!.map((e) => e.toJson()).toList(),
      'total_korban': totalKorban,
      'total_logistik': totalLogistik,
    };
  }

  bool get isMenujuLokasi => statusPenanganan == 'menuju_lokasi';
  bool get isDiLokasi => statusPenanganan == 'di_lokasi';
  bool get isSelesai => statusPenanganan == 'selesai';

  String get statusDisplay {
    switch (statusPenanganan.toLowerCase()) {
      case 'di_lokasi':
        return 'Di Lokasi';
      case 'selesai':
        return 'Selesai';
      case 'menuju_lokasi':
      default:
        return 'Menuju Lokasi';
    }
  }

  Color get statusColor {
    switch (statusPenanganan.toLowerCase()) {
      case 'di_lokasi':
        return AppColors.info;
      case 'selesai':
        return AppColors.success;
      case 'menuju_lokasi':
      default:
        return AppColors.warning;
    }
  }
}

/// Dokumentasi info nested in penanganan.
class DokumentasiInfo {
  final String idDokumentasi;
  final String jenisDokumentasi;
  final String fileDokumentasi;

  const DokumentasiInfo({
    required this.idDokumentasi,
    required this.jenisDokumentasi,
    required this.fileDokumentasi,
  });

  factory DokumentasiInfo.fromJson(Map<String, dynamic> json) {
    return DokumentasiInfo(
      idDokumentasi: json['id_dokumentasi']?.toString() ?? '',
      jenisDokumentasi: json['jenis_dokumentasi']?.toString() ?? 'foto',
      fileDokumentasi: json['file_dokumentasi']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_dokumentasi': idDokumentasi,
      'jenis_dokumentasi': jenisDokumentasi,
      'file_dokumentasi': fileDokumentasi,
    };
  }
}

/// Main monitoring response model.
class MonitoringModel {
  final MonitoringStatistik statistik;
  final List<ActiveOperation> activeOperations;

  const MonitoringModel({
    required this.statistik,
    required this.activeOperations,
  });

  factory MonitoringModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    List<ActiveOperation> parsedOps = [];
    if (data['active_operations'] is List) {
      parsedOps = (data['active_operations'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => ActiveOperation.fromJson(item))
          .toList();
    }

    return MonitoringModel(
      statistik: MonitoringStatistik.fromJson(data['statistik'] as Map<String, dynamic>? ?? {}),
      activeOperations: parsedOps,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statistik': statistik.toJson(),
      'active_operations': activeOperations.map((e) => e.toJson()).toList(),
    };
  }
}