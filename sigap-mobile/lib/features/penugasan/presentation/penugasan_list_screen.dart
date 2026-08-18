import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../alarm/presentation/alarm_controller.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../tim/presentation/tim_controller.dart';
import '../widgets/penugasan_card.dart';
import 'penugasan_controller.dart';
import 'penugasan_detail_screen.dart';

/// Screen displaying all assignments with filtering and assignment creation.
class PenugasanListScreen extends StatefulWidget {
  final PenugasanController penugasanController;
  final AuthController authController;
  final AlarmController alarmController;
  final TimController timController;

  const PenugasanListScreen({
    super.key,
    required this.penugasanController,
    required this.authController,
    required this.alarmController,
    required this.timController,
  });

  @override
  State<PenugasanListScreen> createState() => _PenugasanListScreenState();
}

class _PenugasanListScreenState extends State<PenugasanListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.penugasanController.fetchPenugasanList();
    });
  }

  Widget _buildFilterChip(String label, String? filterKey) {
    final isSelected =
        widget.penugasanController.selectedFilter == filterKey ||
            (filterKey == null &&
                widget.penugasanController.selectedFilter == null);

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
          widget.penugasanController.setFilter(filterKey);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.authController.currentUser?.role.toLowerCase() == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Penugasan Tim'),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan',
            onPressed: () =>
                widget.penugasanController.fetchPenugasanList(isRefresh: true),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.assignment_add),
              label: const Text('Buat Penugasan',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              onPressed: () async {
                final created = await Navigator.of(context)
                    .pushNamed(AppRoutes.penugasanCreate);
                if (created == true) {
                  widget.penugasanController.fetchPenugasanList(isRefresh: true);
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
                  _buildFilterChip('Dalam Proses', 'proses'),
                  _buildFilterChip('Selesai', 'selesai'),
                  _buildFilterChip('Ditolak', 'ditolak'),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),

            // Penugasan List
            Expanded(
              child: ListenableBuilder(
                listenable: widget.penugasanController,
                builder: (context, _) {
                  if (widget.penugasanController.isLoading &&
                      widget.penugasanController.penugasanList.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (widget.penugasanController.errorMessage != null &&
                      widget.penugasanController.penugasanList.isEmpty) {
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
                              widget.penugasanController.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => widget.penugasanController
                                  .fetchPenugasanList(),
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final list = widget.penugasanController.filteredPenugasanList;

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
                                Icons.assignment_outlined,
                                size: 48,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Belum Ada Data Penugasan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Penugasan dibuat oleh Admin dari alarm darurat yang telah diverifikasi.',
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
                    onRefresh: () => widget.penugasanController
                        .fetchPenugasanList(isRefresh: true),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final item = list[index];
                        return PenugasanCard(
                          penugasan: item,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PenugasanDetailScreen(
                                  idPenugasan: item.idPenugasan,
                                  penugasanController:
                                      widget.penugasanController,
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
