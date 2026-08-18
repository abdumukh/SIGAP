import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'alarm_controller.dart';

/// Screen allowing Masyarakat users to submit a new emergency alarm.
class CreateAlarmScreen extends StatefulWidget {
  final AlarmController alarmController;

  const CreateAlarmScreen({
    super.key,
    required this.alarmController,
  });

  @override
  State<CreateAlarmScreen> createState() => _CreateAlarmScreenState();
}

class _CreateAlarmScreenState extends State<CreateAlarmScreen> {
  final _formKey = GlobalKey<FormState>();

  String _selectedJenisDarurat = 'Kebakaran';
  final _customJenisController = TextEditingController();
  final _latitudeController = TextEditingController(text: '-6.208800');
  final _longitudeController = TextEditingController(text: '106.845600');
  String _selectedCuaca = 'Cerah';
  String _selectedLaluLintas = 'Lancar';

  final List<String> _emergencyTypes = [
    'Kebakaran',
    'Medis Darurat',
    'Kecelakaan Lalu Lintas',
    'Bencana Alam',
    'Evakuasi / Penyelamatan',
    'Lainnya',
  ];

  final List<String> _weatherOptions = [
    'Cerah',
    'Berawan',
    'Hujan Ringan',
    'Hujan Lebat',
    'Badai',
  ];

  final List<String> _trafficOptions = [
    'Lancar',
    'Padat Merayap',
    'Macet Total',
  ];

  @override
  void dispose() {
    _customJenisController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _submitAlarm() async {
    if (widget.alarmController.isSubmitting) return;

    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final jenis = _selectedJenisDarurat == 'Lainnya'
        ? _customJenisController.text.trim()
        : _selectedJenisDarurat;

    final lat = double.tryParse(_latitudeController.text.trim()) ?? 0.0;
    final lng = double.tryParse(_longitudeController.text.trim()) ?? 0.0;

    final newAlarm = await widget.alarmController.createAlarm(
      jenisDarurat: jenis,
      latitude: lat,
      longitude: lng,
      cuaca: _selectedCuaca,
      laluLintas: _selectedLaluLintas,
    );

    if (!mounted) return;

    if (newAlarm != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Laporan ${newAlarm.idAlarm} berhasil dikirim!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      final error = widget.alarmController.errorMessage ?? 'Gagal mengirim laporan alarm.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _useCurrentCoordinates() {
    // Default mock coordinates for fast emergency reporting / field testing
    setState(() {
      _latitudeController.text = '-6.208800';
      _longitudeController.text = '106.845600';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Koordinat lokasi saat ini berhasil diset (-6.208800, 106.845600)'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Laporan Darurat'),
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
                // Alert Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.emergencyRedLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.emergencyRed.withAlpha(50)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: AppColors.emergencyRed, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Pastikan informasi yang Anda kirimkan akurat agar tim evakuasi dapat segera merespon.',
                          style: TextStyle(
                            color: AppColors.emergencyRed,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section 1: Jenis Darurat
                const Text(
                  'Jenis Keadaan Darurat *',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _emergencyTypes.map((type) {
                    final isSelected = _selectedJenisDarurat == type;
                    return ChoiceChip(
                      label: Text(
                        type,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.emergencyRed,
                      backgroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected ? AppColors.emergencyRed : AppColors.border,
                        ),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedJenisDarurat = type;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                if (_selectedJenisDarurat == 'Lainnya') ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _customJenisController,
                    decoration: const InputDecoration(
                      labelText: 'Sebutkan jenis darurat',
                      hintText: 'Contoh: Pohon tumbang menimpa jalan',
                    ),
                    validator: (value) {
                      if (_selectedJenisDarurat == 'Lainnya' &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Keterangan jenis darurat wajib diisi';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 24),

                // Section 2: Lokasi Koordinat
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Lokasi Kejadian *',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.my_location_rounded, size: 16),
                      label: const Text('Lokasi Saya', style: TextStyle(fontSize: 13)),
                      onPressed: _useCurrentCoordinates,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latitudeController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        decoration: const InputDecoration(
                          labelText: 'Latitude',
                          hintText: '-6.208800',
                          prefixIcon: Icon(Icons.pin_drop_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Latitude wajib diisi';
                          }
                          final num = double.tryParse(value);
                          if (num == null || num < -90 || num > 90) {
                            return 'Harus antara -90 dan 90';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _longitudeController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        decoration: const InputDecoration(
                          labelText: 'Longitude',
                          hintText: '106.845600',
                          prefixIcon: Icon(Icons.pin_drop_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Longitude wajib diisi';
                          }
                          final num = double.tryParse(value);
                          if (num == null || num < -180 || num > 180) {
                            return 'Harus antara -180 dan 180';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Section 3: Kondisi Lingkungan (Opsional)
                const Text(
                  'Kondisi Lingkungan (Opsional)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Cuaca Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedCuaca,
                  decoration: const InputDecoration(
                    labelText: 'Kondisi Cuaca',
                    prefixIcon: Icon(Icons.cloud_outlined),
                  ),
                  items: _weatherOptions.map((w) {
                    return DropdownMenuItem(value: w, child: Text(w));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCuaca = val);
                  },
                ),
                const SizedBox(height: 16),

                // Lalu Lintas Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedLaluLintas,
                  decoration: const InputDecoration(
                    labelText: 'Kondisi Lalu Lintas Sekitar',
                    prefixIcon: Icon(Icons.traffic_outlined),
                  ),
                  items: _trafficOptions.map((t) {
                    return DropdownMenuItem(value: t, child: Text(t));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedLaluLintas = val);
                  },
                ),
                const SizedBox(height: 32),

                // Submit Button
                ListenableBuilder(
                  listenable: widget.alarmController,
                  builder: (context, _) {
                    final isSubmitting = widget.alarmController.isSubmitting;

                    return ElevatedButton.icon(
                      icon: isSubmitting
                          ? const SizedBox.shrink()
                          : const Icon(Icons.send_rounded, color: Colors.white),
                      label: isSubmitting
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'KIRIM LAPORAN DARURAT',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emergencyRed,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: isSubmitting ? null : _submitAlarm,
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
