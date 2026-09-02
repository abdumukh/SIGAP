import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/notifikasi_model.dart';
import '../../../routes/app_routes.dart';
import 'notifikasi_controller.dart';

class NotificationListScreen extends StatefulWidget {
  final NotifikasiController notifikasiController;

  const NotificationListScreen({
    super.key,
    required this.notifikasiController,
  });

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.notifikasiController.fetchNotifikasiList();
    });
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '-';
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  void _handleNotificationTap(NotifikasiModel notif) async {
    if (notif.isUnread) {
      await widget.notifikasiController.markAsRead(notif.idNotifikasi);
    }

    if (!mounted) return;

    final entityId = notif.entityId;
    if (entityId == null || entityId.isEmpty) return;

    switch (notif.entityRoute) {
      case 'alarmDetail':
        // Navigate via named route if available, or just stay
        break;
      case 'penugasanDetail':
        break;
      case 'penangananDetail':
        Navigator.of(context).pushNamed(
          AppRoutes.penangananDetail,
          arguments: entityId,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            tooltip: 'Tandai semua dibaca',
            onPressed: () => widget.notifikasiController.markAllAsRead(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan',
            onPressed: () => widget.notifikasiController.fetchNotifikasiList(),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.notifikasiController,
        builder: (context, _) {
          if (widget.notifikasiController.isLoading &&
              widget.notifikasiController.notifikasiList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (widget.notifikasiController.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      widget.notifikasiController.errorMessage ?? 'Gagal memuat notifikasi',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => widget.notifikasiController.fetchNotifikasiList(),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final list = widget.notifikasiController.notifikasiList;

          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum Ada Notifikasi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Semua pembaruan penting mengenai laporan dan penanganan darurat akan muncul di sini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => widget.notifikasiController.fetchNotifikasiList(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: list.length,
              separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (context, index) {
                final notif = list[index];
                return ListTile(
                  tileColor: notif.isUnread ? AppColors.primary.withAlpha(8) : null,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: notif.typeColor.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(notif.typeIcon, color: notif.typeColor, size: 22),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notif.isUnread ? FontWeight.w800 : FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (notif.isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        notif.message,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(notif.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  onTap: () => _handleNotificationTap(notif),
                );
              },
            ),
          );
        },
      ),
    );
  }
}