import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/monitoring_model.dart';
import 'monitoring_controller.dart';

class MonitoringScreen extends StatefulWidget {
  final MonitoringController controller;

  const MonitoringScreen({super.key, required this.controller});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.controller.data == null) {
      widget.controller.fetchMonitoring();
    }
  }

  Future<void> _onRefresh() async {
    await widget.controller.fetchMonitoring(isRefresh: true);
  }

  void _showFilterDialog() {
    final TextEditingController startDateCtl = TextEditingController(
      text: widget.controller.startDate ?? '',
    );
    final TextEditingController endDateCtl = TextEditingController(
      text: widget.controller.endDate ?? '',
    );
    final TextEditingController jenisCtl = TextEditingController(
      text: widget.controller.jenisDarurat ?? '',
    );
    final TextEditingController timCtl = TextEditingController(
      text: widget.controller.idTim ?? '',
    );
    String? selectedStatus = widget.controller.statusFilter;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Monitoring'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: startDateCtl,
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Mulai (YYYY-MM-DD)',
                    hintText: '2026-01-01',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: endDateCtl,
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Akhir (YYYY-MM-DD)',
                    hintText: '2026-12-31',
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String?>(
                  initialValue: selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status Alarm'),
                  items: const [
                    DropdownMenuItem<String?>(value: null, child: Text('Semua')),
                    DropdownMenuItem<String?>(value: 'menunggu', child: Text('Menunggu')),
                    DropdownMenuItem<String?>(value: 'diverifikasi', child: Text('Diverifikasi')),
                    DropdownMenuItem<String?>(value: 'ditolak', child: Text('Ditolak')),
                    DropdownMenuItem<String?>(value: 'selesai', child: Text('Selesai')),
                  ],
                  onChanged: (v) => selectedStatus = v,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: jenisCtl,
                  decoration: const InputDecoration(
                    labelText: 'Jenis Darurat',
                    hintText: 'Banjir, Kebakaran, dll.',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: timCtl,
                  decoration: const InputDecoration(
                    labelText: 'ID Tim',
                    hintText: 'TIM-001',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                widget.controller.clearFilters();
                Navigator.pop(context);
              },
              child: const Text('Reset'),
            ),
            ElevatedButton(
              onPressed: () {
                widget.controller.setFilter(
                  startDate: startDateCtl.text.trim().isEmpty ? null : startDateCtl.text.trim(),
                  endDate: endDateCtl.text.trim().isEmpty ? null : endDateCtl.text.trim(),
                  status: selectedStatus,
                  jenisDarurat: jenisCtl.text.trim().isEmpty ? null : jenisCtl.text.trim(),
                  idTim: timCtl.text.trim().isEmpty ? null : timCtl.text.trim(),
                );
                Navigator.pop(context);
              },
              child: const Text('Terapkan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring'),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filter',
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            if (widget.controller.isLoading && widget.controller.data == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (widget.controller.hasError && widget.controller.data == null) {
              return _ErrorView(
                message: widget.controller.errorMessage ?? 'Terjadi kesalahan',
                onRetry: () => widget.controller.fetchMonitoring(),
              );
            }

            if (widget.controller.isEmpty) {
              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 100),
                    const Icon(Icons.inbox_rounded, size: 80, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Belum ada data monitoring',
                        style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Tarik untuk refresh',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              );
            }

            final data = widget.controller.data!;
            final stats = data.statistik;

            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (widget.controller.isRefreshing)
                    const LinearProgressIndicator(minHeight: 2),
                  if (widget.controller.isRefreshing) const SizedBox(height: 8),

                  // Summary Cards Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      _StatCard(
                        title: 'Total Alarm',
                        value: stats.totalAlarm.toString(),
                        icon: Icons.notifications_active_rounded,
                        color: AppColors.primary,
                        bgColor: AppColors.primaryLight.withAlpha(40),
                      ),
                      _StatCard(
                        title: 'Penugasan Aktif',
                        value: stats.penugasanAktif.toString(),
                        icon: Icons.assignment_turned_in_rounded,
                        color: AppColors.info,
                        bgColor: AppColors.infoLight,
                      ),
                      _StatCard(
                        title: 'Penanganan Aktif',
                        value: stats.penangananAktif.toString(),
                        icon: Icons.medical_services_rounded,
                        color: AppColors.warning,
                        bgColor: AppColors.warningLight,
                      ),
                      _StatCard(
                        title: 'Penanganan Selesai',
                        value: stats.penangananSelesai.toString(),
                        icon: Icons.check_circle_rounded,
                        color: AppColors.success,
                        bgColor: AppColors.successLight,
                      ),
                      _StatCard(
                        title: 'Total Korban',
                        value: stats.totalKorban.toString(),
                        icon: Icons.people_rounded,
                        color: AppColors.emergencyRed,
                        bgColor: AppColors.emergencyRedLight,
                      ),
                      _StatCard(
                        title: 'Total Logistik',
                        value: stats.totalLogistik.toString(),
                        icon: Icons.inventory_2_rounded,
                        color: AppColors.rolePetugas,
                        bgColor: AppColors.successLight,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Status Alarm Breakdown
                  if (stats.alarmByStatus.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Alarm Berdasarkan Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: stats.alarmByStatus.entries
                          .map((e) => _StatusChip(
                                label: e.key,
                                value: e.value,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Jenis Darurat Breakdown
                  if (stats.alarmByJenis.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Alarm Berdasarkan Jenis Darurat',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: stats.alarmByJenis.entries
                          .map((e) => Chip(
                                label: Text('${e.key}: ${e.value}'),
                                backgroundColor: AppColors.surface,
                                side: const BorderSide(color: AppColors.border),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Active Operations List
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Operasi Aktif',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  ...data.activeOperations.map((op) => _ActiveOperationCard(op: op)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final int value;

  const _StatusChip({required this.label, required this.value});

  Color get _chipColor {
    switch (label.toLowerCase()) {
      case 'menunggu':
        return AppColors.warning;
      case 'diverifikasi':
        return AppColors.info;
      case 'ditolak':
        return AppColors.error;
      case 'selesai':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _chipColor.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _chipColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _chipColor,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _chipColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveOperationCard extends StatelessWidget {
  final ActiveOperation op;

  const _ActiveOperationCard({required this.op});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  op.jenisDarurat,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: op.statusColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  op.statusDisplay,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: op.statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            op.idAlarm,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  op.coordinateDisplay,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          if (op.waktuAlarm != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  op.waktuAlarm!.toLocal().toString().split('.').first,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
          if (op.penugasanList != null && op.penugasanList!.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            const Text(
              'Penugasan',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            ...op.penugasanList!.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• ${p.namaTim ?? p.idTim} - ${p.statusPenugasan}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
          if (op.penanganan != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.medical_services_rounded,
                  size: 14,
                  color: op.penanganan!.statusColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'Penanganan: ${op.penanganan!.statusDisplay}',
                  style: TextStyle(
                    fontSize: 12,
                    color: op.penanganan!.statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (op.penanganan!.totalKorban > 0) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.people_rounded, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 2),
                  Text(
                    '${op.penanganan!.totalKorban} korban',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isNetworkError = message.toLowerCase().contains('tidak dapat terhubung');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isNetworkError ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
              size: 80,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              isNetworkError ? 'Gagal Terhubung' : 'Terjadi Kesalahan',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}