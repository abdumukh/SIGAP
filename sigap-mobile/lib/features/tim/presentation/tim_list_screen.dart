import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/tim_card.dart';
import 'anggota_tim_controller.dart';
import 'tim_controller.dart';
import 'tim_detail_screen.dart';

/// Screen displaying the list of all teams with filters and create capability.
class TimListScreen extends StatefulWidget {
  final TimController timController;
  final AnggotaTimController anggotaTimController;

  const TimListScreen({
    super.key,
    required this.timController,
    required this.anggotaTimController,
  });

  @override
  State<TimListScreen> createState() => _TimListScreenState();
}

class _TimListScreenState extends State<TimListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.timController.fetchTimList();
    });
  }

  void _showCreateTimDialog() {
    final nameController = TextEditingController();
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Tim Baru'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Tim *',
                  hintText: 'Contoh: Tim Reaksi Cepat 1',
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
                  labelText: 'Catatan (Opsional)',
                  hintText: 'Wilayah operasional atau spesialisasi',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
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
                final created = await widget.timController.createTim(
                  namaTim: nameController.text.trim(),
                  note: noteController.text.trim().isEmpty
                      ? null
                      : noteController.text.trim(),
                );

                if (created != null && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tim "${created.namaTim}" berhasil dibuat'),
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
    );
  }

  Widget _buildFilterChip(String label, String? filterKey) {
    final isSelected = widget.timController.selectedFilter == filterKey ||
        (filterKey == null && widget.timController.selectedFilter == null);

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
          widget.timController.setFilter(filterKey);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Tim SIGAP'),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan',
            onPressed: () => widget.timController.fetchTimList(isRefresh: true),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Tim',
            style: TextStyle(fontWeight: FontWeight.w700)),
        onPressed: _showCreateTimDialog,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _buildFilterChip('Semua Tim', null),
                  _buildFilterChip('Aktif', 'aktif'),
                  _buildFilterChip('Nonaktif', 'nonaktif'),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),

            // Tim List
            Expanded(
              child: ListenableBuilder(
                listenable: widget.timController,
                builder: (context, _) {
                  if (widget.timController.isLoading &&
                      widget.timController.timList.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (widget.timController.errorMessage != null &&
                      widget.timController.timList.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                size: 48, color: AppColors.error),
                            const SizedBox(height: 16),
                            Text(
                              widget.timController.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () =>
                                  widget.timController.fetchTimList(),
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final list = widget.timController.filteredTimList;

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
                                Icons.groups_outlined,
                                size: 48,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Belum Ada Data Tim',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Tekan tombol "Tambah Tim" di bawah untuk membuat tim operasional pertama.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
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
                    onRefresh: () =>
                        widget.timController.fetchTimList(isRefresh: true),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final tim = list[index];
                        return TimCard(
                          tim: tim,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TimDetailScreen(
                                  idTim: tim.idTim,
                                  timController: widget.timController,
                                  anggotaTimController:
                                      widget.anggotaTimController,
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
