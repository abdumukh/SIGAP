import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../auth/presentation/auth_controller.dart';
import '../widgets/alarm_card.dart';
import 'alarm_controller.dart';
import 'alarm_detail_screen.dart';

/// Screen displaying the list of Alarms with filtering and pull-to-refresh.
class AlarmListScreen extends StatefulWidget {
  final AlarmController alarmController;
  final AuthController authController;

  const AlarmListScreen({
    super.key,
    required this.alarmController,
    required this.authController,
  });

  @override
  State<AlarmListScreen> createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends State<AlarmListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.alarmController.fetchAlarms();
    });
  }

  Widget _buildFilterChip(String label, String? filterKey) {
    final isSelected = widget.alarmController.selectedFilter == filterKey ||
        (filterKey == null && widget.alarmController.selectedFilter == null);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
        selected: isSelected,
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        onSelected: (_) {
          widget.alarmController.setFilter(filterKey);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authController.currentUser;
    final isMasyarakat = user == null || user.role.toLowerCase() == 'masyarakat';

    return Scaffold(
      appBar: AppBar(
        title: Text(isMasyarakat ? 'Laporan Darurat Saya' : 'Monitoring Alarm SIGAP'),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan',
            onPressed: () => widget.alarmController.fetchAlarms(isRefresh: true),
          ),
        ],
      ),
      floatingActionButton: isMasyarakat
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.emergencyRed,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_alert_rounded),
              label: const Text('Buat Laporan', style: TextStyle(fontWeight: FontWeight.w700)),
              onPressed: () async {
                final created = await Navigator.of(context).pushNamed(AppRoutes.alarmCreate);
                if (created == true) {
                  widget.alarmController.fetchAlarms(isRefresh: true);
                }
              },
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            // Filter Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _buildFilterChip('Semua', null),
                  _buildFilterChip('Menunggu', 'menunggu'),
                  _buildFilterChip('Diverifikasi', 'diverifikasi'),
                  _buildFilterChip('Selesai', 'selesai'),
                  _buildFilterChip('Ditolak', 'ditolak'),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),

            // Alarm List with RefreshIndicator
            Expanded(
              child: ListenableBuilder(
                listenable: widget.alarmController,
                builder: (context, _) {
                  if (widget.alarmController.isLoading && widget.alarmController.alarms.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (widget.alarmController.errorMessage != null &&
                      widget.alarmController.alarms.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                            const SizedBox(height: 16),
                            Text(
                              widget.alarmController.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => widget.alarmController.fetchAlarms(),
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final list = widget.alarmController.filteredAlarms;

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
                                Icons.notifications_off_outlined,
                                size: 48,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Belum Ada Laporan Alarm',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isMasyarakat
                                  ? 'Tekan tombol "Buat Laporan" untuk mengirim alarm keadaan darurat.'
                                  : 'Tidak ada data alarm yang sesuai dengan filter saat ini.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
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
                    onRefresh: () => widget.alarmController.fetchAlarms(isRefresh: true),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final alarm = list[index];
                        return AlarmCard(
                          alarm: alarm,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AlarmDetailScreen(
                                  alarmId: alarm.idAlarm,
                                  alarmController: widget.alarmController,
                                  authController: widget.authController,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
