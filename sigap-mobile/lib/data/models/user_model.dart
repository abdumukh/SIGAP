/// Unified User Model supporting all 4 backend actors:
/// - Masyarakat (`pengguna`)
/// - Admin (`admin`)
/// - Ketua Tim (`petugas` with role `ketua_tim`)
/// - Petugas (`petugas` with role `petugas`)
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? address;
  final String? status;
  final String role; // 'masyarakat', 'admin', 'ketua_tim', 'petugas'
  final Map<String, dynamic> rawAttributes;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.address,
    this.status,
    required this.role,
    this.rawAttributes = const {},
  });

  /// Factory constructor that dynamically parses different backend user model payloads.
  factory UserModel.fromJson(Map<String, dynamic> json, {String? explicitActor}) {
    // Determine ID from potential model PK fields
    final String id = json['id_pengguna']?.toString() ??
        json['id_admin']?.toString() ??
        json['id_petugas']?.toString() ??
        json['id']?.toString() ??
        '';

    // Determine Name
    final String name = json['nama_admin']?.toString() ??
        json['nama_petugas']?.toString() ??
        json['nama']?.toString() ??
        json['name']?.toString() ??
        'Pengguna SIGAP';

    // Determine Email
    final String email = json['email']?.toString() ?? '';

    // Determine Phone
    final String? phoneNumber = json['no_hp']?.toString() ?? json['phone']?.toString();

    // Determine Address
    final String? address = json['alamat']?.toString() ?? json['address']?.toString();

    // Determine Status
    final String? status = json['status_petugas']?.toString() ?? json['status']?.toString();

    // Determine Role / Actor
    String resolvedRole = explicitActor ?? '';
    if (resolvedRole.isEmpty) {
      if (json.containsKey('id_admin')) {
        resolvedRole = 'admin';
      } else if (json.containsKey('id_petugas')) {
        resolvedRole = json['role']?.toString() == 'ketua_tim' ? 'ketua_tim' : 'petugas';
      } else if (json.containsKey('id_pengguna')) {
        resolvedRole = 'masyarakat';
      } else if (json.containsKey('role')) {
        resolvedRole = json['role'].toString();
      } else {
        resolvedRole = 'masyarakat';
      }
    }

    return UserModel(
      id: id,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      address: address,
      status: status,
      role: resolvedRole,
      rawAttributes: json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'address': address,
      'status': status,
      'role': role,
      'raw_attributes': rawAttributes,
    };
  }

  /// Human-readable role display name.
  String get roleDisplay {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'ketua_tim':
        return 'Ketua Tim';
      case 'petugas':
        return 'Petugas Lapangan';
      case 'masyarakat':
      default:
        return 'Masyarakat';
    }
  }

  @override
  String toString() => 'UserModel(id: $id, name: $name, email: $email, role: $role)';
}
