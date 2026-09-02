import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Data Model representing a Notifikasi from SIGAP backend.
class NotifikasiModel {
  final String idNotifikasi;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final DateTime? readAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isRead;

  const NotifikasiModel({
    required this.idNotifikasi,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    this.readAt,
    this.createdAt,
    this.updatedAt,
    this.isRead = false,
  });

  factory NotifikasiModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return null;
      }
    }

    return NotifikasiModel(
      idNotifikasi: json['id_notifikasi']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : null,
      readAt: parseDate(json['read_at']),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      isRead: json['is_read'] == true,
    );
  }

  bool get isUnread => !isRead;

  String get typeLabel {
    switch (type) {
      case 'ALARM_CREATED':     return 'Laporan Baru';
      case 'ALARM_VERIFIED':    return 'Laporan Diverifikasi';
      case 'ALARM_REJECTED':    return 'Laporan Ditolak';
      case 'ALARM_COMPLETED':   return 'Laporan Ditangani';
      case 'PENUGASAN_CREATED': return 'Penugasan Baru';
      case 'PENANGANAN_STARTED': return 'Penanganan Dimulai';
      case 'PENANGANAN_ARRIVED': return 'Tim Tiba di Lokasi';
      case 'PENANGANAN_COMPLETED': return 'Penanganan Selesai';
      default: return type;
    }
  }

  IconData get typeIcon {
    switch (type) {
      case 'ALARM_CREATED':     return Icons.add_alert_rounded;
      case 'ALARM_VERIFIED':    return Icons.check_circle_rounded;
      case 'ALARM_REJECTED':    return Icons.cancel_rounded;
      case 'ALARM_COMPLETED':   return Icons.task_alt_rounded;
      case 'PENUGASAN_CREATED': return Icons.assignment_ind_rounded;
      case 'PENANGANAN_STARTED': return Icons.medical_services_rounded;
      case 'PENANGANAN_ARRIVED': return Icons.location_on_rounded;
      case 'PENANGANAN_COMPLETED': return Icons.check_circle_outline_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color get typeColor {
    switch (type) {
      case 'ALARM_CREATED':     return AppColors.emergencyRed;
      case 'ALARM_VERIFIED':    return AppColors.info;
      case 'ALARM_REJECTED':    return AppColors.error;
      case 'ALARM_COMPLETED':   return AppColors.success;
      case 'PENUGASAN_CREATED': return AppColors.primary;
      case 'PENANGANAN_STARTED': return AppColors.rolePetugas;
      case 'PENANGANAN_ARRIVED': return AppColors.warning;
      case 'PENANGANAN_COMPLETED': return AppColors.success;
      default: return AppColors.textSecondary;
    }
  }

  String? get entityId {
    if (data == null) return null;
    return data!['id_alarm']?.toString() ??
        data!['id_penugasan']?.toString() ??
        data!['id_penanganan']?.toString();
  }

  String get entityRoute {
    if (data == null) return '';
    if (data!['id_penanganan'] != null) return 'penangananDetail';
    if (data!['id_penugasan'] != null) return 'penugasanDetail';
    if (data!['id_alarm'] != null) return 'alarmDetail';
    return '';
  }
}