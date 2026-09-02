import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/alarm_model.dart';
import '../../../routes/app_routes.dart';
import '../../auth/presentation/auth_controller.dart';
import '../widgets/alarm_status_badge.dart';
import 'alarm_controller.dart';

/// Screen displaying comprehensive details and role-based actions for an Alarm.
class AlarmDetailScreen extends StatefulWidget {
  final String alarmId;
  final AlarmController alarmController;
  final AuthController authController;

  const AlarmDetailScreen({
    super.key,
    required this.alarmId,
    required this.alarmController,
    required this.authController,
  });

  @override
  State<AlarmDetailScreen> createState() => _AlarmDetailScreenState();
}

class _AlarmDetailScreenState extends State<AlarmDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.alarmController.fetchAlarmDetail(widget.alarmId);
    });
  }

  Future<void> _handleVerify(AlarmModel alarm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verifikasi Alarm'),
        content: Text('Apakah Anda yakin ingin memverifikasi alarm ${alarm.idAlarm}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Verifikasi'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await widget.alarmController.verifyAlarm(alarm.idAlarm);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alarm berhasil diverifikasi.'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.alarmController.errorMessage ?? 'Gagal memverifikasi alarm.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleReject(AlarmModel alarm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Alarm'),
        content: Text('Apakah Anda yakin ingin menolak laporan alarm ${alarm.idAlarm}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emergencyRed),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tolak Laporan'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await widget.alarmController.rejectAlarm(alarm.idAlarm);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alarm berhasil ditolak.'),
            backgroundColor: AppColors.warning,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.alarmController.errorMessage ?? 'Gagal menolak alarm.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleComplete(AlarmModel alarm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selesaikan Alarm'),
        content: Text('Tandai penanganan alarm ${alarm.idAlarm} sebagai selesai?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await widget.alarmController.completeAlarm(alarm.idAlarm);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alarm berhasil diselesaikan.'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.alarmController.errorMessage ?? 'Gagal menyelesaikan alarm.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '-';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} WIB';
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    FontWeight? valueWeight,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? AppColors.textPrimary,
                fontSize: 14,
                fontWeight: valueWeight ?? FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required int stepNumber,
    required String title,
    required String? timestamp,
    required bool isDone,
    required bool isCurrent,
    required bool isLast,
  }) {
    final stepColor = isDone
        ? AppColors.success
        : (isCurrent ? AppColors.primary : AppColors.textMuted);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isDone
                    ? AppColors.success
                    : (isCurrent ? AppColors.primary : AppColors.divider),
                shape: BoxShape.circle,
                border: Border.all(color: stepColor, width: 2),
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                    : Text(
                        '$stepNumber',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isCurrent ? Colors.white : AppColors.textMuted,
                        ),
                      ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: isDone ? AppColors.success : AppColors.divider,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isCurrent || isDone ? FontWeight.w800 : FontWeight.w600,
                    color: isCurrent || isDone ? AppColors.textPrimary : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timestamp != null && timestamp.isNotEmpty
                      ? timestamp
                      : (isDone || isCurrent ? 'Sedang berlangsung' : 'Menunggu tahapan sebelumnya'),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDone || isCurrent ? AppColors.textSecondary : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkflowProgress(AlarmModel alarm, BuildContext context, {required bool isStaffOrAdmin}) {
    final penugasan = alarm.latestPenugasan;
    final penanganan = alarm.penanganan;

    // Determine current workflow step
    final isPending = alarm.isPending;
    final isRejected = alarm.isRejected;
    final isVerified = alarm.isVerified && !alarm.hasPenugasan;
    final isAssigned = alarm.hasPenugasan && !alarm.hasPenanganan;
    final isInProgress = alarm.hasPenanganan && penanganan != null && !penanganan.isSelesai;
    final isCompleted = alarm.isCompleted;

    String progressTitle;
    IconData progressIcon;
    Color progressColor;

    if (isPending) {
      progressTitle = 'Menunggu Verifikasi';
      progressIcon = Icons.hourglass_top_rounded;
      progressColor = AppColors.warning;
    } else if (isRejected) {
      progressTitle = 'Laporan Ditolak';
      progressIcon = Icons.cancel_rounded;
      progressColor = AppColors.error;
    } else if (isVerified) {
      progressTitle = 'Menugaskan Tim Operasional';
      progressIcon = Icons.assignment_ind_rounded;
      progressColor = AppColors.info;
    } else if (isAssigned) {
      progressTitle = 'Tim Ditugaskan, Menunggu Penanganan';
      progressIcon = Icons.people_alt_rounded;
      progressColor = AppColors.roleKetuaTim;
    } else if (isInProgress) {
      progressTitle = 'Penanganan Berlangsung';
      progressIcon = Icons.medical_services_rounded;
      progressColor = AppColors.primary;
    } else if (isCompleted) {
      progressTitle = 'Penanganan Selesai';
      progressIcon = Icons.check_circle_rounded;
      progressColor = AppColors.success;
    } else {
      progressTitle = 'Status Tidak Diketahui';
      progressIcon = Icons.help_outline_rounded;
      progressColor = AppColors.textMuted;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(progressIcon, size: 20, color: progressColor),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Progres Penanganan Laporan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 16),

          // Overall Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: progressColor.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: progressColor.withAlpha(80)),
            ),
            child: Row(
              children: [
                Icon(progressIcon, color: progressColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    progressTitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: progressColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Assignment info (when penugasan exists)
          if (penugasan != null) ...[
            _buildInfoRow(
              icon: Icons.groups_rounded,
              label: 'Tim Ditugaskan',
              value: penugasan.timNama ?? penugasan.idTim,
              valueWeight: FontWeight.w700,
            ),
            _buildInfoRow(
              icon: Icons.military_tech_rounded,
              label: 'Ketua Tim',
              value: penugasan.ketuaTimNama ?? penugasan.idKetuaTim,
            ),
            if (penugasan.armadaNama != null)
              _buildInfoRow(
                icon: Icons.directions_car_rounded,
                label: 'Armada',
                value: '${penugasan.armadaNama} (${penugasan.armadaNomor ?? '-'})',
              ),
            _buildInfoRow(
              icon: Icons.access_time_rounded,
              label: 'Waktu Tugas',
              value: penugasan.waktuPenugasan ?? '-',
            ),
            _buildInfoRow(
              icon: Icons.info_outline_rounded,
              label: 'Status Tugas',
              value: penugasan.statusDisplay,
            ),
          ],

          // Penanganan timeline (when penanganan exists)
          if (penanganan != null) ...[
            if (penugasan != null) const SizedBox(height: 8),
            const Text(
              'Timeline Penanganan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _buildTimelineStep(
              stepNumber: 1,
              title: 'Menuju Lokasi',
              timestamp: penanganan.waktuBerangkat,
              isDone: penanganan.isDiLokasi || penanganan.isSelesai,
              isCurrent: penanganan.isMenujuLokasi,
              isLast: false,
            ),
            _buildTimelineStep(
              stepNumber: 2,
              title: 'Tiba di Lokasi',
              timestamp: penanganan.waktuTiba,
              isDone: penanganan.isSelesai,
              isCurrent: penanganan.isDiLokasi,
              isLast: false,
            ),
            _buildTimelineStep(
              stepNumber: 3,
              title: 'Penanganan Selesai',
              timestamp: penanganan.waktuSelesai,
              isDone: penanganan.isSelesai,
              isCurrent: false,
              isLast: true,
            ),
            // Documentation count
            if (alarm.dokumentasiCount != null && alarm.dokumentasiCount! > 0) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.photo_library_rounded,
                label: 'Dokumentasi',
                value: '${alarm.dokumentasiCount} file',
                valueColor: AppColors.info,
              ),
            ],
            // View penanganan link for staff
            if (isStaffOrAdmin) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text(
                    'LIHAT DETAIL PENANGANAN',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.penangananDetail,
                      arguments: penanganan.idPenanganan,
                    );
                  },
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authController.currentUser;
    final isStaffOrAdmin = user != null && user.role.toLowerCase() != 'masyarakat';

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Alarm ${widget.alarmId}'),
        backgroundColor: AppColors.surface,
      ),
      body: ListenableBuilder(
        listenable: widget.alarmController,
        builder: (context, _) {
          if (widget.alarmController.isLoading && widget.alarmController.selectedAlarm == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (widget.alarmController.errorMessage != null &&
              widget.alarmController.selectedAlarm == null) {
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
                      onPressed: () => widget.alarmController.fetchAlarmDetail(widget.alarmId),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final alarm = widget.alarmController.selectedAlarm;
          if (alarm == null) {
            return const Center(child: Text('Data alarm tidak ditemukan'));
          }

          return RefreshIndicator(
            onRefresh: () => widget.alarmController.fetchAlarmDetail(widget.alarmId),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Card: Status & ID
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              alarm.idAlarm,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                            AlarmStatusBadge(alarm: alarm, isLarge: true),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          alarm.jenisDarurat,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dilaporkan pada ${_formatDateTime(alarm.waktuAlarm ?? alarm.createdAt)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Location & Environmental Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi Lokasi & Kondisi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: AppColors.divider, height: 1),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          icon: Icons.pin_drop_rounded,
                          label: 'Koordinat',
                          value: alarm.coordinateDisplay,
                        ),
                        _buildInfoRow(
                          icon: Icons.wb_sunny_rounded,
                          label: 'Cuaca',
                          value: alarm.cuaca ?? 'Tidak tercatat',
                        ),
                        _buildInfoRow(
                          icon: Icons.traffic_rounded,
                          label: 'Lalu Lintas',
                          value: alarm.laluLintas ?? 'Tidak tercatat',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Reporter Information Card (if available)
                  if (alarm.idPengguna.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informasi Pelapor',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: AppColors.divider, height: 1),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            icon: Icons.badge_outlined,
                            label: 'ID Pelapor',
                            value: alarm.idPengguna,
                          ),
                          if (alarm.pelaporName != null)
                            _buildInfoRow(
                              icon: Icons.person_outline,
                              label: 'Nama',
                              value: alarm.pelaporName!,
                            ),
                          if (alarm.pelaporPhone != null)
                            _buildInfoRow(
                              icon: Icons.phone_outlined,
                              label: 'No. HP',
                              value: alarm.pelaporPhone!,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Workflow Progress Section
                  _buildWorkflowProgress(alarm, context, isStaffOrAdmin: isStaffOrAdmin),

                  // Role-Based Operational Action Controls (Admin & Staff)
                  if (isStaffOrAdmin) ...[
                    if (alarm.isPending) ...[
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                        label: const Text(
                          'VERIFIKASI ALARM',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => _handleVerify(alarm),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.cancel_outlined, color: AppColors.emergencyRed),
                        label: const Text(
                          'TOLAK LAPORAN',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.emergencyRed,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.emergencyRed),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => _handleReject(alarm),
                      ),
                    ] else if (alarm.isVerified) ...[
                      if (user.role.toLowerCase() == 'admin') ...[
                        ElevatedButton.icon(
                          icon: const Icon(Icons.assignment_add, color: Colors.white),
                          label: const Text(
                            'TUGASKAN TIM OPERASIONAL',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              '/penugasan/create',
                              arguments: alarm.idAlarm,
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                      ElevatedButton.icon(
                        icon: const Icon(Icons.task_alt_rounded, color: Colors.white),
                        label: const Text(
                          'SELESAIKAN ALARM',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => _handleComplete(alarm),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
