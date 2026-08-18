import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/anggota_tim_model.dart';
import '../../../data/models/tim_model.dart';
import '../../alarm/presentation/alarm_controller.dart';
import '../../tim/presentation/tim_controller.dart';
import 'penugasan_controller.dart';

/// Screen allowing Admin to create a new team assignment for verified alarms.
class CreatePenugasanScreen extends StatefulWidget {
  final PenugasanController penugasanController;
  final AlarmController alarmController;
  final TimController timController;
  final String? initialAlarmId;

  const CreatePenugasanScreen({
    super.key,
    required this.penugasanController,
    required this.alarmController,
    required this.timController,
    this.initialAlarmId,
  });

  @override
  State<CreatePenugasanScreen> createState() => _CreatePenugasanScreenState();
}

class _CreatePenugasanScreenState extends State<CreatePenugasanScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedAlarmId;
  String? _selectedTimId;
  String? _selectedKetuaTimId;
  String? _selectedPetugasArmadaId;
  final _armadaIdController = TextEditingController();
  final _noteController = TextEditingController();

  List<AnggotaTimModel> _currentTeamMembers = [];

  @override
  void initState() {
    super.initState();
    _selectedAlarmId = widget.initialAlarmId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.alarmController.fetchAlarms();
      widget.timController.fetchTimList();
    });
  }

  @override
  void dispose() {
    _armadaIdController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onTimSelected(String? timId) {
    setState(() {
      _selectedTimId = timId;
      _selectedKetuaTimId = null;
      _selectedPetugasArmadaId = null;

      if (timId != null) {
        final tim = widget.timController.timList.firstWhere(
          (t) => t.idTim == timId,
          orElse: () => TimModel(idTim: '', namaTim: '', statusTim: ''),
        );
        _currentTeamMembers = tim.anggotaTim.where((a) => a.isAktif).toList();

        // Auto-select first active ketua tim if available
        final ketua = _currentTeamMembers.where((a) => a.isKetuaTim).firstOrNull;
        if (ketua != null) {
          _selectedKetuaTimId = ketua.idPetugas;
        }
      } else {
        _currentTeamMembers = [];
      }
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedAlarmId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih alarm yang akan ditugaskan.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedTimId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tim operasional.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedKetuaTimId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih Ketua Tim penanggung jawab.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Armada validation: id_petugas_armada and id_armada must be paired
    final armadaId = _armadaIdController.text.trim();
    if ((_selectedPetugasArmadaId != null && armadaId.isEmpty) ||
        (_selectedPetugasArmadaId == null && armadaId.isNotEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Petugas Armada dan ID Armada harus diisi bersamaan jika menggunakan armada.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final created = await widget.penugasanController.createPenugasan(
      idAlarm: _selectedAlarmId!,
      idTim: _selectedTimId!,
      idKetuaTim: _selectedKetuaTimId!,
      idPetugasArmada: _selectedPetugasArmadaId,
      idArmada: armadaId.isNotEmpty ? armadaId : null,
      note: _noteController.text.trim().isNotEmpty
          ? _noteController.text.trim()
          : null,
    );

    if (created != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Penugasan ${created.idPenugasan} berhasil dibuat'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop(true);
    } else if (mounted && widget.penugasanController.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.penugasanController.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Penugasan Tim'),
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
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.infoLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.info.withAlpha(50)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: AppColors.info, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Penugasan hanya dapat diberikan untuk alarm yang telah berstatus "Diverifikasi".',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.info,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Step 1: Pilih Alarm
                const Text(
                  '1. Alarm Darurat *',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                ListenableBuilder(
                  listenable: widget.alarmController,
                  builder: (context, _) {
                    final verifiedAlarms = widget.alarmController.alarms
                        .where((a) => a.isVerified)
                        .toList();

                    return DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedAlarmId,
                      decoration: const InputDecoration(
                        labelText: 'Pilih Alarm Diverifikasi',
                        prefixIcon: Icon(Icons.emergency_outlined),
                      ),
                      items: verifiedAlarms.map((alarm) {
                        return DropdownMenuItem(
                          value: alarm.idAlarm,
                          child: Text(
                            '${alarm.idAlarm} - ${alarm.jenisDarurat} (${alarm.coordinateDisplay})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _selectedAlarmId = val);
                      },
                      validator: (val) {
                        if (val == null && _selectedAlarmId == null) {
                          return 'Alarm wajib dipilih';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Step 2: Pilih Tim Operasional
                const Text(
                  '2. Tim Operasional *',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                ListenableBuilder(
                  listenable: widget.timController,
                  builder: (context, _) {
                    final activeTeams = widget.timController.timList
                        .where((t) => t.isAktif)
                        .toList();

                    return DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedTimId,
                      decoration: const InputDecoration(
                        labelText: 'Pilih Tim Aktif',
                        prefixIcon: Icon(Icons.groups_outlined),
                      ),
                      items: activeTeams.map((tim) {
                        return DropdownMenuItem(
                          value: tim.idTim,
                          child: Text(
                            '${tim.idTim} - ${tim.namaTim} (${tim.anggotaAktifCount} anggota)',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: _onTimSelected,
                      validator: (val) {
                        if (val == null) return 'Tim wajib dipilih';
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Step 3: Pilih Ketua Tim Penanggung Jawab
                const Text(
                  '3. Ketua Tim Penanggung Jawab *',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _selectedKetuaTimId,
                  decoration: const InputDecoration(
                    labelText: 'Pilih Ketua Tim',
                    prefixIcon: Icon(Icons.person_pin_outlined),
                  ),
                  items: _currentTeamMembers.map((member) {
                    return DropdownMenuItem(
                      value: member.idPetugas,
                      child: Text(
                        '${member.displayName} (${member.roleDisplay})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _selectedKetuaTimId = val);
                  },
                  validator: (val) {
                    if (val == null && _selectedKetuaTimId == null) {
                      return 'Ketua Tim wajib dipilih';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Step 4: Armada & Petugas Armada (Opsional)
                const Text(
                  '4. Armada & Petugas Armada (Opsional)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _selectedPetugasArmadaId,
                  decoration: const InputDecoration(
                    labelText: 'Petugas Pengemudi Armada',
                    prefixIcon: Icon(Icons.airline_seat_recline_normal_rounded),
                  ),
                  items: _currentTeamMembers.map((member) {
                    return DropdownMenuItem(
                      value: member.idPetugas,
                      child: Text(
                        '${member.displayName} (${member.roleDisplay})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _selectedPetugasArmadaId = val);
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _armadaIdController,
                  decoration: const InputDecoration(
                    labelText: 'ID Armada Kendaraan',
                    hintText: 'Contoh: ARM-001 (Ambulans / Damkar)',
                    prefixIcon: Icon(Icons.directions_car_outlined),
                  ),
                ),
                const SizedBox(height: 20),

                // Step 5: Catatan & Instruksi
                const Text(
                  '5. Catatan / Instruksi Lapangan (Opsional)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Instruksi Khusus',
                    hintText: 'Misal: Bawa peralatan hidrolik dan P3K lengkap.',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                ListenableBuilder(
                  listenable: widget.penugasanController,
                  builder: (context, _) {
                    final isSubmitting =
                        widget.penugasanController.isSubmitting;

                    return ElevatedButton(
                      onPressed: isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                              'BUAT PENUGASAN SEKARANG',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
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
