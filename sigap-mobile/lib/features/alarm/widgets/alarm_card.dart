import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/alarm_model.dart';
import 'alarm_status_badge.dart';

/// Reusable card displaying summary of an Alarm in a list.
class AlarmCard extends StatelessWidget {
  final AlarmModel alarm;
  final VoidCallback onTap;

  const AlarmCard({
    super.key,
    required this.alarm,
    required this.onTap,
  });

  IconData _getEmergencyIcon(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('kebakaran') || lower.contains('api')) {
      return Icons.local_fire_department_rounded;
    } else if (lower.contains('medis') || lower.contains('sakit') || lower.contains('darurat')) {
      return Icons.medical_services_rounded;
    } else if (lower.contains('kecelakaan') || lower.contains('laka')) {
      return Icons.car_crash_rounded;
    } else if (lower.contains('bencana') || lower.contains('banjir') || lower.contains('gempa')) {
      return Icons.flood_rounded;
    } else if (lower.contains('evakuasi')) {
      return Icons.run_circle_rounded;
    }
    return Icons.warning_amber_rounded;
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '-';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
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
              // Header Row: ID & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          alarm.idAlarm,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDateTime(alarm.waktuAlarm ?? alarm.createdAt),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  AlarmStatusBadge(alarm: alarm),
                ],
              ),
              const SizedBox(height: 12),

              // Emergency Type & Icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.emergencyRedLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getEmergencyIcon(alarm.jenisDarurat),
                      color: AppColors.emergencyRed,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alarm.jenisDarurat,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                alarm.coordinateDisplay,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                  ),
                ],
              ),

              // Optional details chip row (Cuaca / Lalu Lintas / Pelapor)
              if (alarm.cuaca != null || alarm.laluLintas != null || alarm.pelaporName != null) ...[
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    if (alarm.pelaporName != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person_outline, size: 13, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            alarm.pelaporName!,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    if (alarm.cuaca != null && alarm.cuaca!.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.wb_sunny_outlined, size: 13, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            alarm.cuaca!,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    if (alarm.laluLintas != null && alarm.laluLintas!.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.traffic_outlined, size: 13, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            alarm.laluLintas!,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
