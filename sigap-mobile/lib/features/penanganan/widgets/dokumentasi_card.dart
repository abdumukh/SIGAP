import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/dokumentasi_model.dart';

/// Card component for displaying a single field documentation item.
class DokumentasiCard extends StatelessWidget {
  final DokumentasiModel dokumentasi;
  final VoidCallback? onDelete;
  final bool canDelete;

  const DokumentasiCard({
    super.key,
    required this.dokumentasi,
    this.onDelete,
    this.canDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    final isFoto = dokumentasi.isFoto;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Media Thumbnail / Icon representation
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isFoto
                  ? AppColors.primary.withAlpha(20)
                  : AppColors.roleKetuaTim.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isFoto ? Icons.photo_camera_rounded : Icons.videocam_rounded,
              color: isFoto ? AppColors.primary : AppColors.roleKetuaTim,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),

          // Main Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isFoto
                            ? AppColors.primary.withAlpha(15)
                            : AppColors.roleKetuaTim.withAlpha(15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        dokumentasi.jenisDisplay.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isFoto
                              ? AppColors.primary
                              : AppColors.roleKetuaTim,
                        ),
                      ),
                    ),
                    if (canDelete && onDelete != null)
                      InkWell(
                        onTap: onDelete,
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: AppColors.emergencyRed,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  dokumentasi.fileDokumentasi.split('/').last,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (dokumentasi.note != null && dokumentasi.note!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    dokumentasi.note!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.person_rounded,
                        size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      dokumentasi.petugasNama ?? dokumentasi.idPetugas,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.access_time_rounded,
                        size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        dokumentasi.waktuUpload ?? '-',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
