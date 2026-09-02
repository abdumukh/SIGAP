/// Data model for Laporan (rekap) response from API.
/// Supports 5 types: alarm, penugasan, penanganan, pengguna, petugas.
class LaporanModel {
  final String type;
  final int total;
  final List<Map<String, dynamic>> items;

  const LaporanModel({
    required this.type,
    required this.total,
    required this.items,
  });

  factory LaporanModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final type = data['type']?.toString() ?? '';
    final total = data['total'] as int? ?? 0;
    final rawItems = data['items'];

    List<Map<String, dynamic>> parsedItems = [];
    if (rawItems is List) {
      parsedItems = rawItems
          .whereType<Map<String, dynamic>>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return LaporanModel(
      type: type,
      total: total,
      items: parsedItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'total': total,
      'items': items,
    };
  }

  bool get isEmpty => items.isEmpty;

  /// Human-readable type label.
  String get typeLabel {
    switch (type) {
      case 'alarm':
        return 'Laporan Alarm';
      case 'penugasan':
        return 'Laporan Penugasan';
      case 'penanganan':
        return 'Laporan Penanganan';
      case 'pengguna':
        return 'Laporan Pengguna';
      case 'petugas':
        return 'Laporan Petugas';
      default:
        return 'Laporan';
    }
  }
}

/// Rekap filter parameters for laporan endpoint.
class LaporanFilter {
  final String? type;
  final String? startDate;
  final String? endDate;
  final String? status;
  final String? jenisDarurat;
  final String? idTim;
  final String? role;

  const LaporanFilter({
    this.type,
    this.startDate,
    this.endDate,
    this.status,
    this.jenisDarurat,
    this.idTim,
    this.role,
  });

  Map<String, dynamic> toQueryParameters() {
    final Map<String, dynamic> params = {};
    if (type != null && type!.isNotEmpty) params['type'] = type;
    if (startDate != null && startDate!.isNotEmpty) params['start_date'] = startDate;
    if (endDate != null && endDate!.isNotEmpty) params['end_date'] = endDate;
    if (status != null && status!.isNotEmpty) params['status'] = status;
    if (jenisDarurat != null && jenisDarurat!.isNotEmpty) {
      params['jenis_darurat'] = jenisDarurat;
    }
    if (idTim != null && idTim!.isNotEmpty) params['id_tim'] = idTim;
    if (role != null && role!.isNotEmpty) params['role'] = role;
    return params;
  }

  LaporanFilter copyWith({
    String? type,
    String? startDate,
    String? endDate,
    String? status,
    String? jenisDarurat,
    String? idTim,
    String? role,
  }) {
    return LaporanFilter(
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      jenisDarurat: jenisDarurat ?? this.jenisDarurat,
      idTim: idTim ?? this.idTim,
      role: role ?? this.role,
    );
  }

  bool get hasActiveFilter {
    return (startDate?.isNotEmpty == true) ||
        (endDate?.isNotEmpty == true) ||
        (status?.isNotEmpty == true) ||
        (jenisDarurat?.isNotEmpty == true) ||
        (idTim?.isNotEmpty == true) ||
        (role?.isNotEmpty == true);
  }

  void clear() {
    // Note: type preserved by caller; this object is immutable.
  }
}