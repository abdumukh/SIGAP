import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Badge displaying status of Penanganan.
class PenangananStatusBadge extends StatelessWidget {
  final String status;
  final String? label;

  const PenangananStatusBadge({
    super.key,
    required this.status,
    this.label,
  });

  Color _getColor() {
    switch (status.toLowerCase()) {
      case 'menuju_lokasi':
        return AppColors.warning;
      case 'di_lokasi':
        return AppColors.info;
      case 'selesai':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getBgColor() {
    switch (status.toLowerCase()) {
      case 'menuju_lokasi':
        return AppColors.warningLight;
      case 'di_lokasi':
        return AppColors.infoLight;
      case 'selesai':
        return AppColors.successLight;
      default:
        return AppColors.divider;
    }
  }

  String _getDisplayLabel() {
    if (label != null && label!.isNotEmpty) return label!;
    switch (status.toLowerCase()) {
      case 'menuju_lokasi':
        return 'Menuju Lokasi';
      case 'di_lokasi':
        return 'Tiba di Lokasi';
      case 'selesai':
        return 'Selesai';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getBgColor(),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _getDisplayLabel(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: _getColor(),
        ),
      ),
    );
  }
}
