import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/anggota_tim_tile.dart';
import 'anggota_tim_controller.dart';
import 'tim_controller.dart';

/// Screen displaying comprehensive Team details, member roster, and admin operations.
class TimDetailScreen extends StatefulWidget {
  final String idTim;
  final TimController timController;
  final AnggotaTimController anggotaTimController;

  const TimDetailScreen({
    super.key,
    required this.idTim,
    required this.timController,
    required this.anggotaTimController,
  });

  @override
  State<TimDetailScreen> createState() => _TimDetailScreenState();
}

class _TimDetailScreenState extends State<TimDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    widget.timController.fetchTimDetail(widget.idTim);
    widget.anggotaTimController.fetchMembers(widget.idTim);
  }

  void _showEditTimDialog() {
    final tim = widget.timController.selectedTim;
    if (tim == null) return;

    final nameController = TextEditingController(text: tim.namaTim);
    final noteController = TextEditingController(text: tim.note ?? '');
    String selectedStatus = tim.statusTim;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          title: const Text('Ubah Data Tim'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Tim *',
                    prefixIcon: Icon(Icons.group_outlined),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Nama tim wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: noteController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Catatan',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status Tim',
                    prefixIcon: Icon(Icons.toggle_on_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'aktif', child: Text('Aktif')),
                    DropdownMenuItem(value: 'nonaktif', child: Text('Nonaktif')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedStatus = val);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(ctx);
                  final success = await widget.timController.updateTim(
                    widget.idTim,
                    namaTim: nameController.text.trim(),
                    note: noteController.text.trim(),
                    statusTim: selectedStatus,
                  );

                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data tim berhasil diperbarui'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteTimDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Nonaktifkan Tim'),
        content: const Text(
          'Apakah Anda yakin ingin menonaktifkan tim ini? '
          'Tim yang nonaktif tidak dapat dipilih saat membuat penugasan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emergencyRed),
            onPressed: () async {
              Navigator.pop(ctx);
              final success =
                  await widget.timController.deleteTim(widget.idTim);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tim berhasil dinonaktifkan'),
                    backgroundColor: AppColors.warning,
                  ),
                );
              }
            },
            child: const Text('Nonaktifkan'),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog() {
    final idPetugasController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Anggota Tim'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: idPetugasController,
                decoration: const InputDecoration(
                  labelText: 'ID Petugas *',
                  hintText: 'Contoh: PTG-001',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'ID Petugas wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'Masukkan ID petugas terdaftar (Ketua Tim atau Petugas Lapangan).',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(ctx);
                final success = await widget.anggotaTimController.addMember(
                  widget.idTim,
                  idPetugas: idPetugasController.text.trim(),
                );

                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Anggota tim berhasil ditambahkan'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  widget.timController.fetchTimDetail(widget.idTim);
                } else if (mounted &&
                    widget.anggotaTimController.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(widget.anggotaTimController.errorMessage!),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tim'),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Ubah Data Tim',
            onPressed: _showEditTimDialog,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.emergencyRed),
            tooltip: 'Nonaktifkan Tim',
            onPressed: _showDeleteTimDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Team Summary Card
                ListenableBuilder(
                  listenable: widget.timController,
                  builder: (context, _) {
                    final tim = widget.timController.selectedTim;

                    if (widget.timController.isLoading && tim == null) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (tim == null) {
                      return const Center(
                        child: Text('Data tim tidak ditemukan'),
                      );
                    }

                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.roleAdmin, Color(0xFF4C1D95)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.roleAdmin.withAlpha(50),
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
                                  tim.idTim,
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
                                  color: tim.isAktif
                                      ? AppColors.successLight
                                      : AppColors.errorLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  tim.statusDisplay,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: tim.isAktif
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            tim.namaTim,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          if (tim.note != null && tim.note!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              tim.note!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withAlpha(220),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Members Header & Add Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Daftar Anggota Tim',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                      label: const Text('Tambah Anggota',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      onPressed: _showAddMemberDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Members List
                ListenableBuilder(
                  listenable: widget.anggotaTimController,
                  builder: (context, _) {
                    if (widget.anggotaTimController.isLoading &&
                        widget.anggotaTimController.members.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final members = widget.anggotaTimController.members;

                    if (members.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.person_off_outlined,
                                size: 36, color: AppColors.textMuted),
                            SizedBox(height: 8),
                            Text(
                              'Belum ada anggota di tim ini',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Tekan "Tambah Anggota" untuk mendaftarkan ketua tim atau petugas.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        return AnggotaTimTile(
                          member: member,
                          onToggleStatus: () async {
                            final newStatus =
                                member.isAktif ? 'nonaktif' : 'aktif';
                            await widget.anggotaTimController.updateMemberStatus(
                              widget.idTim,
                              member.idAnggotaTim,
                              statusAnggota: newStatus,
                            );
                            widget.timController.fetchTimDetail(widget.idTim);
                          },
                          onRemove: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Hapus Anggota'),
                                content: Text(
                                  'Apakah Anda yakin ingin menonaktifkan "${member.displayName}" dari tim ini?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Batal'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppColors.emergencyRed),
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              await widget.anggotaTimController.removeMember(
                                widget.idTim,
                                member.idAnggotaTim,
                              );
                              widget.timController.fetchTimDetail(widget.idTim);
                            }
                          },
                        );
                      },
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
