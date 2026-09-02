import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../presentation/notifikasi_controller.dart';

class NotificationBadgeIcon extends StatelessWidget {
  final NotifikasiController notifikasiController;

  const NotificationBadgeIcon({
    super.key,
    required this.notifikasiController,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: notifikasiController,
      builder: (context, _) {
        final count = notifikasiController.unreadCount;

        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              tooltip: 'Notifikasi',
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.notifications);
              },
            ),
            if (count > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.emergencyRed,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
