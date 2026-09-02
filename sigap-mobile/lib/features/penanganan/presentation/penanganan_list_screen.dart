import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/presentation/auth_controller.dart';
import '../widgets/penanganan_card.dart';
import 'dokumentasi_controller.dart';
import 'korban_controller.dart';
import 'logistik_controller.dart';
import 'penanganan_controller.dart';
import 'penanganan_detail_screen.dart';

/// Screen displaying accessible Penanganan list with role-based filtering and navigation.
class PenangananListScreen extends StatefulWidget {
  final PenangananController penangananController;
  final DokumentasiController dokumentasiController;
  final KorbanController korbanController;
  final LogistikController logistikController;
  final AuthController authController;

  const PenangananListScreen({
    super.key,
    required this.penangananController,
    required this.dokumentasiController,
    required this.korbanController,
    required this.logistikController,
    required this.authController,
  });

  @override
  State<PenangananListScreen> createState() => _PenangananListScreenState();
}

class _PenangananListScreenState extends State<PenangananListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.penangananController.fetchPenangananList();
    });
  }

  String _getTitle() {
    final role = widget.authController.currentUser?.role.toLowerCase();
    switch (role) {
      case 'admin':
        return 'Monitoring Penanganan';
      case 'ketua_tim':
        return 'Penanganan Tim';
      case 'petugas':
        return 'Penanganan Saya';
      default:
        return 'Daftar Penanganan';
    }
  }

  Widget _buildFilterChip(String label, String? filterKey) {
    final isSelected =
        widget.penangananController.selectedFilter == filterKey ||
            (filterKey == null &&
                widget.penangananController.selectedFilter == null);

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
          widget.penangananController.setFilter(filterKey);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan',
            onPressed: () => widget.penangananController
                .fetchPenangananList(isRefresh: true),
          ),
        ],
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
                  _buildFilterChip('Semua', null),
                  _buildFilterChip('Menuju Lokasi', 'menuju_lokasi'),
                  _buildFilterChip('Di Lokasi', 'di_lokasi'),
                  _buildFilterChip('Selesai', 'selesai'),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),

            // Penanganan List Body
            Expanded(
              child: ListenableBuilder(
                listenable: widget.penangananController,
                builder: (context, _) {
                  if (widget.penangananController.isLoading &&
                      widget.penangananController.penangananList.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (widget.penangananController.errorMessage != null &&
                      widget.penangananController.penangananList.isEmpty) {
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
                              widget.penangananController.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => widget.penangananController
                                  .fetchPenangananList(),
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final list =
                      widget.penangananController.filteredPenangananList;

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
                                Icons.medical_services_outlined,
                                size: 48,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Belum Ada Data Penanganan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Penanganan dimulai oleh Petugas atau Ketua Tim dari Penugasan lapangan.',
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
                    onRefresh: () => widget.penangananController
                        .fetchPenangananList(isRefresh: true),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final item = list[index];
                        return PenangananCard(
                          penanganan: item,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PenangananDetailScreen(
                                  idPenanganan: item.idPenanganan,
                                  penangananController:
                                      widget.penangananController,
                                  dokumentasiController:
                                      widget.dokumentasiController,
                                  korbanController: widget.korbanController,
                                  logistikController: widget.logistikController,
                                  authController: widget.authController,
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
