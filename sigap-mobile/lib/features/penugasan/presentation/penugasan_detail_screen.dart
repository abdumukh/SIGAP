import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../penanganan/presentation/create_penanganan_screen.dart';
import '../../penanganan/presentation/dokumentasi_controller.dart';
import '../../penanganan/presentation/korban_controller.dart';
import '../../penanganan/presentation/logistik_controller.dart';
import '../../penanganan/presentation/penanganan_controller.dart';
import '../../penanganan/presentation/penanganan_detail_screen.dart';
import 'penugasan_controller.dart';

/// Detailed view of a single Penugasan with alarm, team, personnel, vehicle specs, and action trigger.
class PenugasanDetailScreen extends StatefulWidget {
  final String idPenugasan;
  final PenugasanController penugasanController;
  final AuthController? authController;
  final PenangananController? penangananController;
  final DokumentasiController? dokumentasiController;
  final KorbanController? korbanController;
  final LogistikController? logistikController;

  const PenugasanDetailScreen({
    super.key,
    required this.idPenugasan,
    required this.penugasanController,
    this.authController,
    this.penangananController,
    this.dokumentasiController,
    this.korbanController,
    this.logistikController,
  });

  @override
  State<PenugasanDetailScreen> createState() => _PenugasanDetailScreenState();
}

class _PenugasanDetailScreenState extends State<PenugasanDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.penugasanController.fetchPenugasanDetail(widget.idPenugasan);
    });
  }

  bool _canStartPenanganan() {
    if (widget.authController == null) return false;
    final role = widget.authController!.currentUser?.role.toLowerCase();
    return role == 'petugas' || role == 'ketua_tim';
  }

  bool _hasExistingPenanganan() {
    if (widget.penangananController == null) return false;
    final list = widget.penangananController!.penangananList;
    return list.any((p) => p.idPenugasan == widget.idPenugasan);
  }

  Widget _buildPenangananButton() {
    final canStart = _canStartPenanganan();
    final hasExisting = _hasExistingPenanganan();

    if (!canStart) return const SizedBox.shrink();

    if (hasExisting) {
      // Already has penanganan - show "LIHAT" button
      return ElevatedButton.icon(
        icon: const Icon(Icons.remove_circle_outlined),
        label: const Text(
          'LIHAT PENANGANAN',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.info,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () {
          final controller = widget.penangananController!;
            final existingPenanganan = controller.penangananList
              .firstWhere((p) => p.idPenugasan == widget.idPenugasan);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PenangananDetailScreen(
                  idPenanganan: existingPenanganan.idPenanganan,
                  penangananController: widget.penangananController!,
                  dokumentasiController: widget.dokumentasiController!,
                  korbanController: widget.korbanController!,
                  logistikController: widget.logistikController!,
                  authController: widget.authController!,
                ),
              ),
            );
        },
      );
    } else {
      // No existing penanganan - show "MULAI PENANGANAN"
      return ElevatedButton.icon(
        icon: const Icon(Icons.medical_services_rounded),
        label: const Text(
          'MULAI PENANGANAN',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CreatePenangananScreen(
                idPenugasan: widget.penugasanController.selectedPenugasan!.idPenugasan,
                idAlarm: widget.penugasanController.selectedPenugasan!.idAlarm,
                alarmJenisDarurat: widget.penugasanController.selectedPenugasan!.alarmJenisDarurat,
                penangananController: widget.penangananController!,
                dokumentasiController: widget.dokumentasiController!,
                korbanController: widget.korbanController!,
                logistikController: widget.logistikController!,
                authController: widget.authController!,
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor, FontWeight? valueWeight}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: valueWeight ?? FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Penugasan'),
        backgroundColor: AppColors.surface,
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.penugasanController,
          builder: (context, _) {
            final penugasan = widget.penugasanController.selectedPenugasan;

            if (widget.penugasanController.isLoading && penugasan == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (penugasan == null) {
              return const Center(
                child: Text('Data penugasan tidak ditemukan'),
              );
            }

            final canStart = _canStartPenanganan();

            return RefreshIndicator(
              onRefresh: () async => widget.penugasanController
                  .fetchPenugasanDetail(widget.idPenugasan),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Banner Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFF1E40AF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(50),
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(40),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  penugasan.idPenugasan,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  penugasan.statusDisplay,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            penugasan.alarmJenisDarurat ?? 'Penugasan Operasional',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Waktu: ${penugasan.waktuPenugasan ?? 'Belum tercatat'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withAlpha(200),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Operational Action Button for Authorized Field Personnel
                    if (canStart && widget.penangananController != null && widget.dokumentasiController != null) ...[
                      _buildPenangananButton(),
                      const SizedBox(height: 24),
                    ],

                    // Section 1: Alarm Terkait
                    _buildSectionHeader('Informasi Alarm Darurat', Icons.emergency_rounded),
                    _buildInfoCard([
                      _buildInfoRow('ID Alarm', penugasan.idAlarm, valueWeight: FontWeight.w700),
                      _buildInfoRow('Jenis Darurat', penugasan.alarmJenisDarurat ?? '-'),
                      _buildInfoRow('Status Alarm', penugasan.alarmStatus ?? '-'),
                      if (penugasan.alarmLatitude != null && penugasan.alarmLongitude != null)
                        _buildInfoRow(
                          'Koordinat',
                          '${penugasan.alarmLatitude!.toStringAsFixed(6)}, ${penugasan.alarmLongitude!.toStringAsFixed(6)}',
                        ),
                    ]),

                    // Section 2: Tim Operasional
                    _buildSectionHeader('Tim yang Ditugaskan', Icons.groups_rounded),
                    _buildInfoCard([
                      _buildInfoRow('ID Tim', penugasan.idTim),
                      _buildInfoRow('Nama Tim', penugasan.timNama ?? '-', valueWeight: FontWeight.w700),
                      _buildInfoRow('Status Tim', penugasan.timStatus ?? '-'),
                    ]),

                    // Section 3: Personel Lapangan
                    _buildSectionHeader('Personel', Icons.badge_rounded),
                    _buildInfoCard([
                      _buildInfoRow('Ketua Tim', '${penugasan.ketuaTimNama ?? '-'} (${penugasan.idKetuaTim})',
                          valueWeight: FontWeight.w700, valueColor: AppColors.roleKetuaTim),
                      if (penugasan.idPetugasArmada != null)
                        _buildInfoRow('Petugas Armada',
                            '${penugasan.petugasArmadaNama ?? '-'} (${penugasan.idPetugasArmada})'),
                    ]),

                    // Section 4: Armada Kendaraan (jika ada)
                    if (penugasan.hasArmada) ...[
                      _buildSectionHeader('Armada Kendaraan', Icons.directions_car_rounded),
                      _buildInfoCard([
                        _buildInfoRow('ID Armada', penugasan.idArmada!),
                        _buildInfoRow('Nama Armada', penugasan.armadaNama ?? '-'),
                        _buildInfoRow('Jenis Armada', penugasan.armadaJenis ?? '-'),
                        _buildInfoRow('Nomor Kendaraan', penugasan.armadaNomor ?? '-',
                            valueWeight: FontWeight.w700),
                        _buildInfoRow('Status Armada', penugasan.armadaStatus ?? '-'),
                      ]),
                    ],

                    // Section 5: Catatan Penugasan
                    if (penugasan.note != null && penugasan.note!.isNotEmpty) ...[
                      _buildSectionHeader('Instruksi & Catatan', Icons.notes_rounded),
                      _buildInfoCard([
                        Text(
                          penugasan.note!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ]),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
