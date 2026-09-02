import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../alarm/presentation/alarm_controller.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../notifikasi/presentation/notifikasi_controller.dart';
import '../../notifikasi/widgets/notification_badge_icon.dart';

class MasyarakatDashboardScreen extends StatelessWidget {
  final AuthController authController;
  final AlarmController alarmController;
  final NotifikasiController notifikasiController;

  const MasyarakatDashboardScreen({
    super.key,
    required this.authController,
    required this.alarmController,
    required this.notifikasiController,
  });

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emergencyRed),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await authController.logout();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = authController.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Masyarakat'),
        backgroundColor: AppColors.surface,
        actions: [
          NotificationBadgeIcon(notifikasiController: notifikasiController),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.emergencyRed),
            tooltip: 'Logout',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Identity Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.roleMasyarakat, Color(0xFF0369A1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.roleMasyarakat.withAlpha(70),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(50),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_rounded, size: 14, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                'MASYARAKAT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          user?.id ?? '-',
                          style: TextStyle(
                            color: Colors.white.withAlpha(200),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.name ?? 'Masyarakat SIGAP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        color: Colors.white.withAlpha(220),
                        fontSize: 14,
                      ),
                    ),
                    if (user?.phoneNumber != null && user!.phoneNumber!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'No. HP: ${user.phoneNumber}',
                        style: TextStyle(
                          color: Colors.white.withAlpha(200),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Big Emergency SOS Button Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.emergencyRedLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.emergencyRed.withAlpha(60)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.emergency_rounded,
                      size: 48,
                      color: AppColors.emergencyRed,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'PANGGILAN DARURAT (SOS)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.emergencyRed,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Laporkan kejadian darurat seperti kebakaran, medis kritis, atau bencana alam untuk respon cepat.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_alert_rounded, color: Colors.white),
                      label: const Text(
                        'KIRIM LAPORAN DARURAT',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emergencyRed,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.alarmCreate);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Cards: Riwayat Alarm
              InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.alarms);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: AppColors.infoLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.history_rounded, color: AppColors.info, size: 24),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Riwayat Laporan Saya',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Pantau status verifikasi dan penanganan laporan',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Logout Button
              OutlinedButton.icon(
                icon: const Icon(Icons.logout_rounded, color: AppColors.emergencyRed),
                label: const Text('Keluar dari Akun', style: TextStyle(color: AppColors.emergencyRed)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.emergencyRed),
                ),
                onPressed: () => _handleLogout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
