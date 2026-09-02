import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/presentation/auth_controller.dart';
import '../widgets/dokumentasi_card.dart';
import '../widgets/korban_card.dart';
import '../widgets/logistik_card.dart';
import '../widgets/penanganan_status_badge.dart';
import 'dokumentasi_controller.dart';
import 'korban_controller.dart';
import 'logistik_controller.dart';
import 'penanganan_controller.dart';

/// Screen displaying comprehensive details of a Penanganan, status progression timeline,
/// action buttons for status transitions, field documentation management,
/// and korban/logistik data management.
class PenangananDetailScreen extends StatefulWidget {
  final String idPenanganan;
  final PenangananController penangananController;
  final DokumentasiController dokumentasiController;
  final KorbanController korbanController;
  final LogistikController logistikController;
  final AuthController authController;

  const PenangananDetailScreen({
    super.key,
    required this.idPenanganan,
    required this.penangananController,
    required this.dokumentasiController,
    required this.korbanController,
    required this.logistikController,
    required this.authController,
  });

  @override
  State<PenangananDetailScreen> createState() => _PenangananDetailScreenState();
}

class _PenangananDetailScreenState extends State<PenangananDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    widget.penangananController.fetchPenangananDetail(widget.idPenanganan);
    widget.dokumentasiController.fetchDokumentasiList(isRefresh: true);
    widget.korbanController.fetchKorbanList(isRefresh: true);
    widget.logistikController.fetchLogistikList(isRefresh: true);
  }

  bool _canUserUpdateStatus() {
    final user = widget.authController.currentUser;
    if (user == null) return false;
    final role = user.role.toLowerCase();
    if (role == 'admin' || role == 'masyarakat') return false;

    final penanganan = widget.penangananController.selectedPenanganan;
    if (penanganan != null && penanganan.idPetugas == user.id) {
      return true;
    }

    return false;
  }

  bool _canUserUploadDokumentasi() {
    final user = widget.authController.currentUser;
    if (user == null) return false;
    final role = user.role.toLowerCase();
    return role == 'petugas' || role == 'ketua_tim';
  }

  bool _canUserManageKorbanLogistik() {
    final user = widget.authController.currentUser;
    if (user == null) return false;
    final role = user.role.toLowerCase();
    return role == 'petugas' || role == 'ketua_tim';
  }

  bool _canUserDeleteKorbanLogistik() {
    final user = widget.authController.currentUser;
    if (user == null) return false;
    final role = user.role.toLowerCase();
    return role == 'petugas' || role == 'ketua_tim';
  }

  Future<void> _handleStatusUpdate(String targetStatus) async {
    final penanganan = widget.penangananController.selectedPenanganan;
    if (penanganan == null) return;

    final noteController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          targetStatus == 'di_lokasi'
              ? 'Konfirmasi Tiba di Lokasi'
              : 'Konfirmasi Penyelesaian',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              targetStatus == 'di_lokasi'
                  ? 'Apakah tim sudah tiba di lokasi kejadian darurat?'
                  : 'Apakah seluruh tindakan penanganan darurat telah selesai?',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 14),
            const Text(
              'Catatan Tambahan (Opsional):',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                hintText: 'Kondisi di lokasi, tindakan yang dilakukan...',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: targetStatus == 'di_lokasi'
                  ? AppColors.primary
                  : AppColors.success,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              targetStatus == 'di_lokasi'
                  ? 'Konfirmasi Tiba'
                  : 'Selesaikan Penanganan',
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final note = noteController.text.trim();
      final updated = await widget.penangananController.updateStatus(
        widget.idPenanganan,
        targetStatus: targetStatus,
        note: note.isNotEmpty ? note : null,
      );

      if (updated != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Status penanganan berhasil diubah ke ${updated.statusDisplay}!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (widget.penangananController.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.penangananController.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showAddDokumentasiModal(BuildContext context) {
    String jenis = 'foto';
    final noteController = TextEditingController();
    final fileController = TextEditingController(text: 'dokumentasi/foto_lapangan_${DateTime.now().millisecondsSinceEpoch}.jpg');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tambah Dokumentasi Lapangan',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Choice chips for jenis (foto vs video)
                const Text(
                  'Jenis Dokumentasi',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Row(
                        children: [
                          Icon(Icons.photo_camera_rounded, size: 16),
                          SizedBox(width: 6),
                          Text('Foto'),
                        ],
                      ),
                      selected: jenis == 'foto',
                      onSelected: (selected) {
                        if (selected) {
                          setModalState(() {
                            jenis = 'foto';
                            fileController.text =
                                'dokumentasi/foto_${DateTime.now().millisecondsSinceEpoch}.jpg';
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Row(
                        children: [
                          Icon(Icons.videocam_rounded, size: 16),
                          SizedBox(width: 6),
                          Text('Video'),
                        ],
                      ),
                      selected: jenis == 'video',
                      onSelected: (selected) {
                        if (selected) {
                          setModalState(() {
                            jenis = 'video';
                            fileController.text =
                                'dokumentasi/video_${DateTime.now().millisecondsSinceEpoch}.mp4';
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // File name / simulation field
                const Text(
                  'File Media',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: fileController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      jenis == 'foto'
                          ? Icons.image_rounded
                          : Icons.video_file_rounded,
                      color: AppColors.primary,
                    ),
                    hintText: 'Nama file dokumentasi',
                  ),
                ),
                const SizedBox(height: 16),

                // Note field
                const Text(
                  'Catatan / Keterangan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: noteController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Keterangan dokumentasi (cth: Evakuasi korban, Pemadaman titik api)...',
                  ),
                ),
                const SizedBox(height: 24),

                // Upload Button
                ListenableBuilder(
                  listenable: widget.dokumentasiController,
                  builder: (context, _) {
                    final isUploading =
                        widget.dokumentasiController.isUploading;

                    return ElevatedButton(
                      onPressed: isUploading
                          ? null
                          : () async {
                              final note = noteController.text.trim();
                              final file = fileController.text.trim();

                              final messenger = ScaffoldMessenger.of(context);
                              Navigator.pop(ctx);

                              final created = await widget
                                  .dokumentasiController
                                  .uploadDokumentasi(
                                idPenanganan: widget.idPenanganan,
                                jenisDokumentasi: jenis,
                                file: file.isNotEmpty
                                    ? file
                                    : 'dokumentasi/default.jpg',
                                note: note.isNotEmpty ? note : null,
                              );

                              if (created != null && mounted) {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Dokumentasi berhasil diunggah!'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isUploading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'UNGGAH DOKUMENTASI',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddKorbanModal(BuildContext context) {
    String jenisKelamin = 'L';
    final namaController = TextEditingController();
    final usiaController = TextEditingController();
    final kondisiController = TextEditingController();
    final statusPenangananController = TextEditingController();
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tambah Data Korban',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Nama Korban
                const Text(
                  'Nama Korban',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan nama korban',
                    prefixIcon: Icon(Icons.person_rounded),
                  ),
                  maxLength: 75,
                ),
                const SizedBox(height: 16),

                // Jenis Kelamin
                const Text(
                  'Jenis Kelamin',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Laki-laki'),
                      selected: jenisKelamin == 'L',
                      onSelected: (selected) {
                        if (selected) setModalState(() => jenisKelamin = 'L');
                      },
                    ),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text('Perempuan'),
                      selected: jenisKelamin == 'P',
                      onSelected: (selected) {
                        if (selected) setModalState(() => jenisKelamin = 'P');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Usia
                const Text(
                  'Usia (Tahun)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: usiaController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan usia (0-150)',
                    prefixIcon: Icon(Icons.cake_rounded),
                  ),
                  maxLength: 3,
                ),
                const SizedBox(height: 16),

                // Kondisi
                const Text(
                  'Kondisi',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: kondisiController,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Luka ringan, Selamat, Kritis',
                    prefixIcon: Icon(Icons.medical_services_rounded),
                  ),
                  maxLength: 50,
                ),
                const SizedBox(height: 16),

                // Status Penanganan
                const Text(
                  'Status Penanganan Korban',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: statusPenangananController,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Dievakuasi ke RS, Ditampung di Posko, Rawat Jalan',
                    prefixIcon: Icon(Icons.local_hospital_rounded),
                  ),
                  maxLength: 50,
                ),
                const SizedBox(height: 16),

                // Catatan
                const Text(
                  'Catatan / Keterangan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: noteController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Keterangan tambahan (opsional)...',
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                ListenableBuilder(
                  listenable: widget.korbanController,
                  builder: (context, _) {
                    final isCreating = widget.korbanController.isCreating;

                    return ElevatedButton(
                      onPressed: isCreating
                          ? null
                          : () async {
                              final nama = namaController.text.trim();
                              final usiaStr = usiaController.text.trim();
                              final kondisi = kondisiController.text.trim();
                              final statusPenanganan = statusPenangananController.text.trim();
                              final note = noteController.text.trim();

                              if (nama.isEmpty ||
                                  usiaStr.isEmpty ||
                                  kondisi.isEmpty ||
                                  statusPenanganan.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Mohon isi semua field wajib'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                                return;
                              }

                              final usia = int.tryParse(usiaStr) ?? 0;
                              if (usia < 0 || usia > 150) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Usia tidak valid (0-150)'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                                return;
                              }

                              final messenger = ScaffoldMessenger.of(context);
                              Navigator.pop(ctx);

                              final created = await widget.korbanController.createKorban(
                                idPenanganan: widget.idPenanganan,
                                namaKorban: nama,
                                jenisKelamin: jenisKelamin,
                                usia: usia,
                                kondisi: kondisi,
                                statusPenanganan: statusPenanganan,
                                note: note.isNotEmpty ? note : null,
                              );

                              if (created != null && mounted) {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Data korban berhasil ditambahkan!'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isCreating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'TAMBAH KORBAN',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddLogistikModal(BuildContext context) {
    final namaController = TextEditingController();
    final jumlahController = TextEditingController();
    final satuanController = TextEditingController();
    final kondisiController = TextEditingController();
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tambah Data Logistik',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Nama Logistik
                const Text(
                  'Nama Logistik',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Selang Pemadam, Masker Gas, Tangki Air',
                    prefixIcon: Icon(Icons.inventory_2_rounded),
                  ),
                  maxLength: 75,
                ),
                const SizedBox(height: 16),

                // Jumlah & Satuan
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Jumlah',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: jumlahController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Jumlah',
                              prefixIcon: Icon(Icons.numbers_rounded),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Satuan',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: satuanController,
                            decoration: const InputDecoration(
                              hintText: 'Contoh: Unit, Pcs, Box, Meter',
                              prefixIcon: Icon(Icons.straighten_rounded),
                            ),
                            maxLength: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Kondisi
                const Text(
                  'Kondisi',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: kondisiController,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Baik, Rusak, Perlu Perbaikan',
                    prefixIcon: Icon(Icons.build_rounded),
                  ),
                  maxLength: 30,
                ),
                const SizedBox(height: 16),

                // Catatan
                const Text(
                  'Catatan / Keterangan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: noteController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Keterangan tambahan (opsional)...',
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                ListenableBuilder(
                  listenable: widget.logistikController,
                  builder: (context, _) {
                    final isCreating = widget.logistikController.isCreating;

                    return ElevatedButton(
                      onPressed: isCreating
                          ? null
                          : () async {
                              final nama = namaController.text.trim();
                              final jumlahStr = jumlahController.text.trim();
                              final satuan = satuanController.text.trim();
                              final kondisi = kondisiController.text.trim();
                              final note = noteController.text.trim();

                              if (nama.isEmpty ||
                                  jumlahStr.isEmpty ||
                                  satuan.isEmpty ||
                                  kondisi.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Mohon isi semua field wajib'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                                return;
                              }

                              final jumlah = int.tryParse(jumlahStr) ?? 0;
                              if (jumlah < 1) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Jumlah minimal 1'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                                return;
                              }

                              final messenger = ScaffoldMessenger.of(context);
                              Navigator.pop(ctx);

                              final created = await widget.logistikController.createLogistik(
                                idPenanganan: widget.idPenanganan,
                                namaLogistik: nama,
                                jumlah: jumlah,
                                satuan: satuan,
                                kondisi: kondisi,
                                note: note.isNotEmpty ? note : null,
                              );

                              if (created != null && mounted) {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Data logistik berhasil ditambahkan!'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.roleKetuaTim,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isCreating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'TAMBAH LOGISTIK',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
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

  Widget _buildInfoRow(String label, String value,
      {Color? valueColor, FontWeight? valueWeight}) {
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
                    : (isCurrent
                        ? AppColors.primary
                        : AppColors.divider),
                shape: BoxShape.circle,
                border: Border.all(
                  color: stepColor,
                  width: 2,
                ),
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check_rounded,
                        size: 16, color: Colors.white)
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
                    fontWeight: isCurrent || isDone
                        ? FontWeight.w800
                        : FontWeight.w600,
                    color: isCurrent || isDone
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timestamp != null && timestamp.isNotEmpty
                      ? timestamp
                      : (isDone || isCurrent ? 'Sedang berlangsung' : 'Menunggu tahapan sebelumnya'),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDone || isCurrent
                        ? AppColors.textSecondary
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Penanganan Lapangan'),
        backgroundColor: AppColors.surface,
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.penangananController,
          builder: (context, _) {
            final penanganan =
                widget.penangananController.selectedPenanganan;

            if (widget.penangananController.isLoading && penanganan == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (penanganan == null) {
              return const Center(
                child: Text('Data penanganan tidak ditemukan'),
              );
            }

            final isMenujuLokasi = penanganan.isMenujuLokasi;
            final isDiLokasi = penanganan.isDiLokasi;
            final isSelesai = penanganan.isSelesai;
            final canUpdate = _canUserUpdateStatus();
            final canUpload = _canUserUploadDokumentasi();

            return RefreshIndicator(
              onRefresh: () async => _loadData(),
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
                                  penanganan.idPenanganan,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              PenangananStatusBadge(
                                status: penanganan.statusPenanganan,
                                label: penanganan.statusDisplay,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            penanganan.alarmJenisDarurat ??
                                'Penanganan Operasional',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pelaksana: ${penanganan.petugasNama ?? penanganan.idPetugas}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withAlpha(220),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section 1: Timeline Progression
                    _buildSectionHeader(
                        'Tahapan Penanganan Lapangan', Icons.timeline_rounded),
                    _buildInfoCard([
                      _buildTimelineStep(
                        stepNumber: 1,
                        title: '1. Menuju Lokasi Kejadian',
                        timestamp: penanganan.waktuBerangkat != null
                            ? 'Waktu Berangkat: ${penanganan.waktuBerangkat}'
                            : null,
                        isDone: isDiLokasi || isSelesai,
                        isCurrent: isMenujuLokasi,
                        isLast: false,
                      ),
                      _buildTimelineStep(
                        stepNumber: 2,
                        title: '2. Tiba & Penanganan di Lokasi',
                        timestamp: penanganan.waktuTiba != null
                            ? 'Waktu Tiba: ${penanganan.waktuTiba}'
                            : null,
                        isDone: isSelesai,
                        isCurrent: isDiLokasi,
                        isLast: false,
                      ),
                      _buildTimelineStep(
                        stepNumber: 3,
                        title: '3. Penanganan Selesai',
                        timestamp: penanganan.waktuSelesai != null
                            ? 'Waktu Selesai: ${penanganan.waktuSelesai}'
                            : null,
                        isDone: isSelesai,
                        isCurrent: false,
                        isLast: true,
                      ),
                    ]),

                    // Status Action Button for Authorized Field Personnel
                    if (canUpdate && !isSelesai) ...[
                      if (isMenujuLokasi)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.location_on_rounded),
                          label: const Text(
                            'SUDAH TIBA DI LOKASI',
                            style: TextStyle(
                              fontSize: 14,
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
                          onPressed: widget.penangananController.isUpdating
                              ? null
                              : () => _handleStatusUpdate('di_lokasi'),
                        ),
                      if (isDiLokasi)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle_rounded),
                          label: const Text(
                            'SELESAIKAN PENANGANAN',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: widget.penangananController.isUpdating
                              ? null
                              : () => _handleStatusUpdate('selesai'),
                        ),
                      const SizedBox(height: 24),
                    ],

                    if (isSelesai) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.success),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle_rounded,
                                color: AppColors.success, size: 24),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Penanganan ini telah selesai dan ditutup secara resmi.',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Section 2: Informasi Alarm
                    _buildSectionHeader('Informasi Alarm Terkait',
                        Icons.emergency_rounded),
                    _buildInfoCard([
                      _buildInfoRow('ID Alarm', penanganan.idAlarm,
                          valueWeight: FontWeight.w700),
                      _buildInfoRow('Jenis Darurat',
                          penanganan.alarmJenisDarurat ?? '-'),
                      _buildInfoRow(
                          'Status Alarm', penanganan.alarmStatus ?? '-'),
                      if (penanganan.alarmLatitude != null &&
                          penanganan.alarmLongitude != null)
                        _buildInfoRow(
                          'Koordinat',
                          '${penanganan.alarmLatitude!.toStringAsFixed(6)}, ${penanganan.alarmLongitude!.toStringAsFixed(6)}',
                        ),
                    ]),

                    // Section 3: Informasi Penugasan
                    _buildSectionHeader('Informasi Penugasan',
                        Icons.assignment_turned_in_rounded),
                    _buildInfoCard([
                      _buildInfoRow('ID Penugasan', penanganan.idPenugasan,
                          valueWeight: FontWeight.w700),
                      _buildInfoRow('ID Tim',
                          penanganan.penugasanIdTim ?? '-'),
                      _buildInfoRow('Status Penugasan',
                          penanganan.penugasanStatus ?? '-'),
                    ]),

                    // Section 4: Catatan Penanganan
                    if (penanganan.note != null &&
                        penanganan.note!.isNotEmpty) ...[
                      _buildSectionHeader(
                          'Catatan Lapangan', Icons.notes_rounded),
                      _buildInfoCard([
                        Text(
                          penanganan.note!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ]),
                    ],

                    // Section 5: Data Korban
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionHeader('Data Korban',
                            Icons.person_off_rounded),
                        if (_canUserManageKorbanLogistik())
                          TextButton.icon(
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: const Text('+ Tambah',
                                style:
                                    TextStyle(fontWeight: FontWeight.w700)),
                            onPressed: () =>
                                _showAddKorbanModal(context),
                          ),
                      ],
                    ),
                    ListenableBuilder(
                      listenable: widget.korbanController,
                      builder: (context, _) {
                        final korbanList = widget.korbanController
                            .getKorbanForPenanganan(widget.idPenanganan);

                        if (widget.korbanController.isLoading &&
                            korbanList.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (korbanList.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(24),
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.person_off_rounded,
                                    size: 40, color: AppColors.textMuted),
                                const SizedBox(height: 10),
                                const Text(
                                  'Belum ada data korban',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                if (_canUserManageKorbanLogistik()) ...[
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.add_rounded,
                                        size: 18),
                                    label: const Text(
                                        'Tambah Data Korban'),
                                    onPressed: () =>
                                        _showAddKorbanModal(context),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: korbanList.map((korban) {
                            final canDeleteItem =
                                _canUserDeleteKorbanLogistik();

                            return KorbanCard(
                              korban: korban,
                              canDelete: canDeleteItem,
                              onDelete: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Hapus Data Korban'),
                                    content: Text(
                                        'Apakah Anda yakin ingin menghapus data korban ${korban.namaKorban}?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Batal'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.emergencyRed),
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text('Hapus'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true && mounted) {
                                  await widget.korbanController
                                      .deleteKorban(korban.idKorban);
                                }
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),

                    // Section 6: Data Logistik
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionHeader('Data Logistik',
                            Icons.inventory_2_rounded),
                        if (_canUserManageKorbanLogistik())
                          TextButton.icon(
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: const Text('+ Tambah',
                                style:
                                    TextStyle(fontWeight: FontWeight.w700)),
                            onPressed: () =>
                                _showAddLogistikModal(context),
                          ),
                      ],
                    ),
                    ListenableBuilder(
                      listenable: widget.logistikController,
                      builder: (context, _) {
                        final logistikList = widget.logistikController
                            .getLogistikForPenanganan(widget.idPenanganan);

                        if (widget.logistikController.isLoading &&
                            logistikList.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (logistikList.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(24),
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.inventory_2_rounded,
                                    size: 40, color: AppColors.textMuted),
                                const SizedBox(height: 10),
                                const Text(
                                  'Belum ada data logistik',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                if (_canUserManageKorbanLogistik()) ...[
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.add_rounded,
                                        size: 18),
                                    label: const Text(
                                        'Tambah Data Logistik'),
                                    onPressed: () =>
                                        _showAddLogistikModal(context),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: logistikList.map((logistik) {
                            final canDeleteItem =
                                _canUserDeleteKorbanLogistik();

                            return LogistikCard(
                              logistik: logistik,
                              canDelete: canDeleteItem,
                              onDelete: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Hapus Data Logistik'),
                                    content: Text(
                                        'Apakah Anda yakin ingin menghapus data logistik ${logistik.namaLogistik}?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Batal'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.emergencyRed),
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text('Hapus'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true && mounted) {
                                  await widget.logistikController
                                      .deleteLogistik(logistik.idLogistik);
                                }
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),

                    // Section 7: Field Documentation (Dokumentasi Lapangan)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionHeader('Dokumentasi Lapangan',
                            Icons.perm_media_rounded),
                        if (canUpload)
                          TextButton.icon(
                            icon: const Icon(Icons.add_photo_alternate_rounded,
                                size: 16),
                            label: const Text('+ Tambah',
                                style:
                                    TextStyle(fontWeight: FontWeight.w700)),
                            onPressed: () =>
                                _showAddDokumentasiModal(context),
                          ),
                      ],
                    ),
                    ListenableBuilder(
                      listenable: widget.dokumentasiController,
                      builder: (context, _) {
                        final docs = widget.dokumentasiController
                            .getDokumentasiForPenanganan(
                                widget.idPenanganan);

                        if (widget.dokumentasiController.isLoading &&
                            docs.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (docs.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(24),
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.photo_library_outlined,
                                    size: 40, color: AppColors.textMuted),
                                const SizedBox(height: 10),
                                const Text(
                                  'Belum ada dokumentasi lapangan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                if (canUpload) ...[
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.add_rounded,
                                        size: 18),
                                    label: const Text(
                                        'Tambah Foto/Video Dokumentasi'),
                                    onPressed: () =>
                                        _showAddDokumentasiModal(context),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }

                        final currentUserId =
                            widget.authController.currentUser?.id;
                        final isAdmin =
                            widget.authController.currentUser?.role.toLowerCase() == 'admin';

                        return Column(
                          children: docs.map((doc) {
                            final canDeleteDoc =
                                isAdmin || (currentUserId != null && doc.idPetugas == currentUserId);

                            return DokumentasiCard(
                              dokumentasi: doc,
                              canDelete: canDeleteDoc,
                              onDelete: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Hapus Dokumentasi'),
                                    content: const Text(
                                        'Apakah Anda yakin ingin menghapus dokumentasi ini?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Batal'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.emergencyRed),
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text('Hapus'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true && mounted) {
                                  await widget.dokumentasiController
                                      .deleteDokumentasi(
                                          doc.idDokumentasi);
                                }
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
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
