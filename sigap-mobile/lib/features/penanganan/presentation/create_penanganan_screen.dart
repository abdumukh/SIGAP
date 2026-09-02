import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/presentation/auth_controller.dart';
import 'dokumentasi_controller.dart';
import 'korban_controller.dart';
import 'logistik_controller.dart';
import 'penanganan_controller.dart';
import 'penanganan_detail_screen.dart';

/// Screen for creating and starting a new Penanganan from an assigned Penugasan.
class CreatePenangananScreen extends StatefulWidget {
  final String idPenugasan;
  final String? alarmJenisDarurat;
  final String? idAlarm;
  final PenangananController penangananController;
  final DokumentasiController dokumentasiController;
  final KorbanController korbanController;
  final LogistikController logistikController;
  final AuthController authController;

  const CreatePenangananScreen({
    super.key,
    required this.idPenugasan,
    this.alarmJenisDarurat,
    this.idAlarm,
    required this.penangananController,
    required this.dokumentasiController,
    required this.korbanController,
    required this.logistikController,
    required this.authController,
  });

  @override
  State<CreatePenangananScreen> createState() => _CreatePenangananScreenState();
}

class _CreatePenangananScreenState extends State<CreatePenangananScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final note = _noteController.text.trim();
    final created = await widget.penangananController.createPenanganan(
      idPenugasan: widget.idPenugasan,
      note: note.isNotEmpty ? note : null,
    );

    if (created != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Penanganan ${created.idPenanganan} berhasil dimulai!'),
          backgroundColor: AppColors.success,
        ),
      );

      // Navigate to PenangananDetailScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PenangananDetailScreen(
            idPenanganan: created.idPenanganan,
            penangananController: widget.penangananController,
            dokumentasiController: widget.dokumentasiController,
            korbanController: widget.korbanController,
            logistikController: widget.logistikController,
            authController: widget.authController,
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mulai Penanganan Lapangan'),
        backgroundColor: AppColors.surface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Banner
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF1E40AF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Konfirmasi Keberangkatan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Dengan menekan tombol Mulai Penanganan, status penanganan akan otomatis disetel ke "Menuju Lokasi" dan waktu keberangkatan akan dicatat.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withAlpha(220),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Assignment details summary card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Penugasan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('ID Penugasan',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary)),
                          Text(widget.idPenugasan,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                        ],
                      ),
                      if (widget.idAlarm != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('ID Alarm',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary)),
                            Text(widget.idAlarm!,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                          ],
                        ),
                      ],
                      if (widget.alarmJenisDarurat != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Jenis Darurat',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary)),
                            Text(widget.alarmJenisDarurat!,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.emergencyRed)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Catatan / Note Field
                const Text(
                  'Catatan Tambahan (Opsional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText:
                        'Masukkan catatan awal keberangkatan (misal: Rute tercepat melalui jalan tol, bawa perlengkapan ekstra)...',
                  ),
                ),
                const SizedBox(height: 28),

                // Submit Button
                ListenableBuilder(
                  listenable: widget.penangananController,
                  builder: (context, _) {
                    final isSubmitting =
                        widget.penangananController.isSubmitting;

                    return ElevatedButton(
                      onPressed: isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'MULAI PENANGANAN',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
