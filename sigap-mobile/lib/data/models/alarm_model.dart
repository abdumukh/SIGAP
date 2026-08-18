import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Data Model representing an Alarm (Laporan Darurat) from SIGAP backend.
class AlarmModel {
  final String idAlarm;
  final String idPengguna;
  final String jenisDarurat;
  final DateTime? waktuAlarm;
  final double latitude;
  final double longitude;
  final String? cuaca;
  final String? laluLintas;
  final String statusAlarm; // 'menunggu', 'diverifikasi', 'ditolak', 'selesai'
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? penggunaData;

  const AlarmModel({
    required this.idAlarm,
    required this.idPengguna,
    required this.jenisDarurat,
    this.waktuAlarm,
    required this.latitude,
    required this.longitude,
    this.cuaca,
    this.laluLintas,
    required this.statusAlarm,
    this.createdAt,
    this.updatedAt,
    this.penggunaData,
  });

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
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

    return AlarmModel(
      idAlarm: json['id_alarm']?.toString() ?? '',
      idPengguna: json['id_pengguna']?.toString() ?? '',
      jenisDarurat: json['jenis_darurat']?.toString() ?? 'Darurat',
      waktuAlarm: parseDate(json['waktu_alarm']),
      latitude: parseDouble(json['latitude'], 0.0),
      longitude: parseDouble(json['longitude'], 0.0),
      cuaca: json['cuaca']?.toString(),
      laluLintas: json['lalu_lintas']?.toString(),
      statusAlarm: json['status_alarm']?.toString() ?? 'menunggu',
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      penggunaData: json['pengguna'] is Map<String, dynamic>
          ? json['pengguna'] as Map<String, dynamic>
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_alarm': idAlarm,
      'id_pengguna': idPengguna,
      'jenis_darurat': jenisDarurat,
      'waktu_alarm': waktuAlarm?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'cuaca': cuaca,
      'lalu_lintas': laluLintas,
      'status_alarm': statusAlarm,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      if (penggunaData != null) 'pengguna': penggunaData,
    };
  }

  // --- Helper Getters ---

  bool get isPending => statusAlarm == 'menunggu';
  bool get isVerified => statusAlarm == 'diverifikasi';
  bool get isRejected => statusAlarm == 'ditolak';
  bool get isCompleted => statusAlarm == 'selesai';

  /// Human-readable localized status title.
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

  /// Status badge color according to SIGAP design tokens.
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

  /// Status badge background light color.
  Color get statusBackgroundColor {
    switch (statusAlarm.toLowerCase()) {
      case 'diverifikasi':
        return AppColors.infoLight;
      case 'ditolak':
        return AppColors.errorLight;
      case 'selesai':
        return AppColors.successLight;
      case 'menunggu':
      default:
        return AppColors.warningLight;
    }
  }

  /// Pelapor name if attached in response.
  String? get pelaporName => penggunaData?['nama']?.toString();

  /// Pelapor phone number if attached.
  String? get pelaporPhone => penggunaData?['no_hp']?.toString();

  /// Formatted coordinates representation.
  String get coordinateDisplay =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
}
