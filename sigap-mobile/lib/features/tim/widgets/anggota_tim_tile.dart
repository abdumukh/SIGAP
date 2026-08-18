import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/anggota_tim_model.dart';

/// Tile displaying an individual team member with role badges and actions.
class AnggotaTimTile extends StatelessWidget {
  final AnggotaTimModel member;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onRemove;

  const AnggotaTimTile({
    super.key,
    required this.member,
    this.onToggleStatus,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isKetua = member.isKetuaTim;
    final isAktif = member.isAktif;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isKetua
              ? AppColors.roleKetuaTim.withAlpha(80)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          // Avatar Icon with Role indicator
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isKetua
                  ? AppColors.roleKetuaTim.withAlpha(25)
                  : AppColors.rolePetugas.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isKetua
                  ? Icons.military_tech_rounded
                  : Icons.badge_rounded,
              color: isKetua
                  ? AppColors.roleKetuaTim
                  : AppColors.rolePetugas,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Member Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        member.displayName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Role Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isKetua
                            ? AppColors.roleKetuaTim.withAlpha(20)
                            : AppColors.rolePetugas.withAlpha(20),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        member.roleDisplay,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isKetua
                              ? AppColors.roleKetuaTim
                              : AppColors.rolePetugas,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${member.idPetugas}${member.noHp != null ? ' • ${member.noHp}' : ''}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isAktif
                  ? AppColors.successLight
                  : AppColors.errorLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              member.statusDisplay,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isAktif
                    ? AppColors.success
                    : AppColors.error,
              ),
            ),
          ),

          // Action Menu
          if (onToggleStatus != null || onRemove != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded,
                  size: 20, color: AppColors.textSecondary),
              onSelected: (value) {
                if (value == 'toggle' && onToggleStatus != null) {
                  onToggleStatus!();
                } else if (value == 'remove' && onRemove != null) {
                  onRemove!();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        isAktif
                            ? Icons.pause_circle_outline_rounded
                            : Icons.play_circle_outline_rounded,
                        size: 18,
                        color: isAktif
                            ? AppColors.warning
                            : AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      Text(isAktif ? 'Nonaktifkan' : 'Aktifkan'),
                    ],
                  ),
                ),
                if (onRemove != null)
                  const PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.person_remove_outlined,
                            size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Hapus Anggota',
                            style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
