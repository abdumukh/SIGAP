import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'laporan_controller.dart';

class LaporanScreen extends StatefulWidget {
  final LaporanController controller;
  final String initialType;
  final List<String> allowedTypes;

  const LaporanScreen({
    super.key,
    required this.controller,
    this.initialType = 'alarm',
    this.allowedTypes = const ['alarm', 'penugasan', 'penanganan', 'pengguna', 'petugas'],
  });

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    if (!widget.allowedTypes.contains(_selectedType)) {
      _selectedType = widget.allowedTypes.first;
    }
    widget.controller.fetchLaporan(type: _selectedType);
  }

  Future<void> _onRefresh() async {
    await widget.controller.fetchLaporan(
      type: _selectedType,
      isRefresh: true,
    );
  }

  void _onTypeChanged(String newType) {
    setState(() => _selectedType = newType);
    widget.controller.fetchLaporan(type: newType);
  }

  void _showFilterDialog() {
    final TextEditingController startCtl = TextEditingController(
      text: widget.controller.currentFilter.startDate ?? '',
    );
    final TextEditingController endCtl = TextEditingController(
      text: widget.controller.currentFilter.endDate ?? '',
    );
    final TextEditingController statusCtl = TextEditingController(
      text: widget.controller.currentFilter.status ?? '',
    );
    final TextEditingController jenisCtl = TextEditingController(
      text: widget.controller.currentFilter.jenisDarurat ?? '',
    );
    final TextEditingController timCtl = TextEditingController(
      text: widget.controller.currentFilter.idTim ?? '',
    );
    final TextEditingController roleCtl = TextEditingController(
      text: widget.controller.currentFilter.role ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Laporan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: startCtl,
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Mulai (YYYY-MM-DD)',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: endCtl,
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Akhir (YYYY-MM-DD)',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: statusCtl,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                  ),
                ),
                const SizedBox(height: 8),
                if (_selectedType == 'alarm' || _selectedType == 'penugasan' || _selectedType == 'penanganan')
                  TextField(
                    controller: jenisCtl,
                    decoration: const InputDecoration(
                      labelText: 'Jenis Darurat',
                    ),
                  ),
                if (_selectedType == 'penugasan')
                  TextField(
                    controller: timCtl,
                    decoration: const InputDecoration(
                      labelText: 'ID Tim',
                    ),
                  ),
                if (_selectedType == 'petugas')
                  TextField(
                    controller: roleCtl,
                    decoration: const InputDecoration(
                      labelText: 'Role (petugas / ketua_tim)',
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                widget.controller.fetchLaporan(type: _selectedType);
                Navigator.pop(context);
              },
              child: const Text('Reset'),
            ),
            ElevatedButton(
              onPressed: () {
                widget.controller.fetchLaporan(
                  type: _selectedType,
                  startDate: startCtl.text.trim().isEmpty ? null : startCtl.text.trim(),
                  endDate: endCtl.text.trim().isEmpty ? null : endCtl.text.trim(),
                  status: statusCtl.text.trim().isEmpty ? null : statusCtl.text.trim(),
                  jenisDarurat: jenisCtl.text.trim().isEmpty ? null : jenisCtl.text.trim(),
                  idTim: timCtl.text.trim().isEmpty ? null : timCtl.text.trim(),
                  role: roleCtl.text.trim().isEmpty ? null : roleCtl.text.trim(),
                );
                Navigator.pop(context);
              },
              child: const Text('Terapkan'),
            ),
          ],
        );
      },
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'alarm':
        return 'Alarm';
      case 'penugasan':
        return 'Penugasan';
      case 'penanganan':
        return 'Penanganan';
      case 'pengguna':
        return 'Pengguna';
      case 'petugas':
        return 'Petugas';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan'),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filter',
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (widget.allowedTypes.length > 1)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                color: AppColors.background,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: widget.allowedTypes
                        .map((t) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text(_typeLabel(t)),
                                selected: _selectedType == t,
                                onSelected: (_) => _onTypeChanged(t),
                                selectedColor: AppColors.primary,
                                backgroundColor: AppColors.surface,
                                labelStyle: TextStyle(
                                  color: _selectedType == t
                                      ? AppColors.textWhite
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                side: BorderSide(
                                  color: _selectedType == t
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            Expanded(
              child: AnimatedBuilder(
                animation: widget.controller,
                builder: (context, _) {
                  if (widget.controller.isLoading && widget.controller.data == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (widget.controller.hasError && widget.controller.data == null) {
                    return _ErrorView(
                      message: widget.controller.errorMessage ?? 'Terjadi kesalahan',
                      onRetry: () => widget.controller.fetchLaporan(type: _selectedType),
                    );
                  }

                  if (widget.controller.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 100),
                          const Icon(Icons.inbox_rounded, size: 80, color: AppColors.textMuted),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              'Tidak ada data ${_typeLabel(_selectedType)}',
                              style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final data = widget.controller.data!;
                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          color: AppColors.primary.withAlpha(20),
                          child: Text(
                            'Total: ${data.total} ${_typeLabel(_selectedType)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: data.items.length,
                            itemBuilder: (context, index) {
                              return _LaporanItemCard(
                                type: data.type,
                                item: data.items[index],
                              );
                            },
                          ),
                        ),
                      ],
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

class _LaporanItemCard extends StatelessWidget {
  final String type;
  final Map<String, dynamic> item;

  const _LaporanItemCard({required this.type, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildFields(),
      ),
    );
  }

  List<Widget> _buildFields() {
    final List<Widget> widgets = [];

    String? primaryText;
    String? secondaryText;
    String? statusText;
    String? dateText;

    switch (type) {
      case 'alarm':
        primaryText = item['jenis_darurat']?.toString();
        secondaryText = item['id_alarm']?.toString();
        statusText = item['status_alarm']?.toString();
        dateText = item['waktu_alarm']?.toString();
        break;
      case 'penugasan':
        primaryText = item['id_penugasan']?.toString();
        if (item['alarm'] is Map) {
          secondaryText = item['alarm']['jenis_darurat']?.toString();
        }
        statusText = item['status_penugasan']?.toString();
        dateText = item['waktu_penugasan']?.toString();
        break;
      case 'penanganan':
        primaryText = item['id_penanganan']?.toString();
        if (item['alarm'] is Map) {
          secondaryText = item['alarm']['jenis_darurat']?.toString();
        }
        statusText = item['status_penanganan']?.toString();
        dateText = item['waktu_berangkat']?.toString();
        break;
      case 'pengguna':
        primaryText = item['nama']?.toString();
        secondaryText = item['id_pengguna']?.toString();
        if (item['email'] != null) {
          widgets.add(_kv('Email', item['email'].toString()));
        }
        if (item['no_hp'] != null) {
          widgets.add(_kv('No HP', item['no_hp'].toString()));
        }
        break;
      case 'petugas':
        primaryText = item['nama_petugas']?.toString();
        secondaryText = item['id_petugas']?.toString();
        statusText = item['status_petugas']?.toString();
        if (item['role'] != null) {
          widgets.add(_kv('Role', item['role'].toString()));
        }
        if (item['email'] != null) {
          widgets.add(_kv('Email', item['email'].toString()));
        }
        break;
    }

    if (primaryText != null) {
      widgets.add(
        Text(
          primaryText,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      );
    }
    if (secondaryText != null && secondaryText.isNotEmpty) {
      widgets.add(const SizedBox(height: 2));
      widgets.add(
        Text(
          secondaryText,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    if (statusText != null && statusText.isNotEmpty) {
      widgets.add(const SizedBox(height: 6));
      widgets.add(_statusBadge(statusText));
    }
    if (dateText != null && dateText.isNotEmpty) {
      widgets.add(const SizedBox(height: 6));
      widgets.add(
        Text(
          dateText.split('T').join(' ').split('.').first,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      );
    }

    return widgets;
  }

  Widget _kv(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        '$key: $value',
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color = AppColors.primary;
    switch (status.toLowerCase()) {
      case 'menunggu':
        color = AppColors.warning;
        break;
      case 'diverifikasi':
      case 'di_lokasi':
        color = AppColors.info;
        break;
      case 'ditolak':
        color = AppColors.error;
        break;
      case 'selesai':
        color = AppColors.success;
        break;
      case 'berangkat':
        color = AppColors.info;
        break;
      case 'diterima':
        color = AppColors.success;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isNetworkError = message.toLowerCase().contains('tidak dapat terhubung');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isNetworkError ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
              size: 80,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              isNetworkError ? 'Gagal Terhubung' : 'Terjadi Kesalahan',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}