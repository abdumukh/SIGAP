import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/penanganan_model.dart';
import 'penanganan_status_badge.dart';

/// Card displaying summarized Penanganan info for list view.
class PenangananCard extends StatelessWidget {
  final PenangananModel penanganan;
  final VoidCallback onTap;

  const PenangananCard({
    super.key,
    required this.penanganan,
    required this.onTap,
  });

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
              // Header: ID Penanganan & Status Badge
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
                      penanganan.idPenanganan,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  PenangananStatusBadge(
                    status: penanganan.statusPenanganan,
                    label: penanganan.statusDisplay,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Emergency Type & ID Alarm
              Row(
                children: [
                  const Icon(Icons.emergency_rounded,
                      size: 18, color: AppColors.emergencyRed),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${penanganan.alarmJenisDarurat ?? 'Penanganan Darurat'} (${penanganan.idAlarm})',
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

              // Assigned Personnel & Penugasan Info
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
                        const Icon(Icons.badge_rounded,
                            size: 16, color: AppColors.rolePetugas),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Pelaksana: ${penanganan.petugasNama ?? penanganan.idPetugas}',
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
                        const Icon(Icons.assignment_rounded,
                            size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Penugasan: ${penanganan.idPenugasan}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (penanganan.note != null && penanganan.note!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.notes_rounded,
                              size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              penanganan.note!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
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

              // Footer: Timestamps & Navigation Chevron
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        penanganan.waktuSelesai != null
                            ? 'Selesai: ${penanganan.waktuSelesai}'
                            : (penanganan.waktuTiba != null
                                ? 'Tiba: ${penanganan.waktuTiba}'
                                : 'Berangkat: ${penanganan.waktuBerangkat ?? 'Baru saja'}'),
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
