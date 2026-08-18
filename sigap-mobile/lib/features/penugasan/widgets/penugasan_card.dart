import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/penugasan_model.dart';

/// Card displaying summarized Penugasan info.
class PenugasanCard extends StatelessWidget {
  final PenugasanModel penugasan;
  final VoidCallback onTap;

  const PenugasanCard({
    super.key,
    required this.penugasan,
    required this.onTap,
  });

  Color _getStatusColor() {
    switch (penugasan.statusPenugasan) {
      case 'menunggu':
        return AppColors.warning;
      case 'proses':
        return AppColors.info;
      case 'selesai':
        return AppColors.success;
      case 'ditolak':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getStatusBgColor() {
    switch (penugasan.statusPenugasan) {
      case 'menunggu':
        return AppColors.warningLight;
      case 'proses':
        return AppColors.infoLight;
      case 'selesai':
        return AppColors.successLight;
      case 'ditolak':
        return AppColors.errorLight;
      default:
        return AppColors.divider;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: ID Penugasan & Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      penugasan.idPenugasan,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusBgColor(),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      penugasan.statusDisplay,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: _getStatusColor(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Alarm Emergency Type & ID
              Row(
                children: [
                  const Icon(Icons.emergency_rounded,
                      size: 18, color: AppColors.emergencyRed),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${penugasan.alarmJenisDarurat ?? 'Kejadian Darurat'} (${penugasan.idAlarm})',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Assigned Team & Leader
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.groups_rounded,
                            size: 16, color: AppColors.roleKetuaTim),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tim: ${penugasan.timNama ?? penugasan.idTim}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person_pin_rounded,
                            size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Ketua: ${penugasan.ketuaTimNama ?? penugasan.idKetuaTim}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (penugasan.hasArmada) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.directions_car_rounded,
                              size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Armada: ${penugasan.armadaNama ?? penugasan.idArmada!} (${penugasan.armadaNomor ?? ''})',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Footer: Time & Details Chevron
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        penugasan.waktuPenugasan ?? 'Baru saja',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textMuted),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
