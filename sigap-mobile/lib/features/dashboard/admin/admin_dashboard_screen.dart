import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../alarm/presentation/alarm_controller.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../laporan/presentation/laporan_controller.dart';
import '../../monitoring/presentation/monitoring_controller.dart';
import '../../notifikasi/presentation/notifikasi_controller.dart';
import '../../notifikasi/widgets/notification_badge_icon.dart';
import '../../penugasan/presentation/penugasan_controller.dart';
import '../../tim/presentation/tim_controller.dart';

class AdminDashboardScreen extends StatelessWidget {
  final AuthController authController;
  final AlarmController alarmController;
  final TimController timController;
  final PenugasanController penugasanController;
  final NotifikasiController notifikasiController;
  final MonitoringController monitoringController;
  final LaporanController laporanController;

  const AdminDashboardScreen({
    super.key,
    required this.authController,
    required this.alarmController,
    required this.timController,
    required this.penugasanController,
    required this.notifikasiController,
    required this.monitoringController,
    required this.laporanController,
  });

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun Administrator?'),
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

  Widget _buildMenuCard({
    required BuildContext context,
    required String route,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(route);
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
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = authController.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Administrator'),
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
                    colors: [AppColors.roleAdmin, Color(0xFF5B21B6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.roleAdmin.withAlpha(70),
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
                              Icon(Icons.shield_rounded, size: 14, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                'ADMINISTRATOR',
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
                      user?.name ?? 'Admin SIGAP',
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
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Operational Section Title
              const Text(
                'Menu Operasional',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Operational Card 1: Monitoring & Verifikasi Alarm
              _buildMenuCard(
                context: context,
                route: AppRoutes.alarms,
                icon: Icons.notifications_active_rounded,
                iconColor: AppColors.warning,
                iconBgColor: AppColors.warningLight,
                title: 'Monitoring & Verifikasi Alarm',
                subtitle: 'Verifikasi atau tolak alarm masuk dari masyarakat',
              ),

              // Operational Card 2: Manajemen Tim
              _buildMenuCard(
                context: context,
                route: AppRoutes.tim,
                icon: Icons.groups_rounded,
                iconColor: AppColors.roleAdmin,
                iconBgColor: AppColors.roleAdmin.withAlpha(25),
                title: 'Manajemen Tim',
                subtitle: 'Kelola data tim operasional dan daftar anggota',
              ),

              // Operational Card 3: Penugasan Tim
              _buildMenuCard(
                context: context,
                route: AppRoutes.penugasan,
                icon: Icons.assignment_turned_in_rounded,
                iconColor: AppColors.primary,
                iconBgColor: AppColors.primary.withAlpha(25),
                title: 'Penugasan Tim Lapangan',
                subtitle: 'Tugaskan tim untuk alarm yang sudah diverifikasi',
              ),

              // Operational Card 4: Monitoring Penanganan
              _buildMenuCard(
                context: context,
                route: AppRoutes.penanganan,
                icon: Icons.medical_services_rounded,
                iconColor: AppColors.rolePetugas,
                iconBgColor: AppColors.rolePetugas.withAlpha(25),
                title: 'Monitoring Penanganan',
                subtitle: 'Pantau status penanganan dan dokumentasi lapangan',
              ),

              // Operational Card 5: Monitoring Dashboard
              _buildMenuCard(
                context: context,
                route: AppRoutes.monitoring,
                icon: Icons.dashboard_rounded,
                iconColor: AppColors.info,
                iconBgColor: AppColors.infoLight,
                title: 'Dashboard Monitoring',
                subtitle: 'Statistik operasional dan pemantauan real-time',
              ),

              // Operational Card 6: Laporan
              _buildMenuCard(
                context: context,
                route: AppRoutes.laporan,
                icon: Icons.assessment_rounded,
                iconColor: AppColors.roleAdmin,
                iconBgColor: AppColors.roleAdmin.withAlpha(25),
                title: 'Laporan & Rekap',
                subtitle: 'Rekap data alarm, penugasan, penanganan, pengguna, petugas',
              ),

              const SizedBox(height: 16),

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
