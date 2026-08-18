import 'package:flutter_test/flutter_test.dart';
import 'package:sigap_mobile/data/models/user_model.dart';

void main() {
  group('UserModel JSON Parsing Tests', () {
    test('parses Masyarakat payload correctly', () {
      final json = {
        'id_pengguna': 'USR-001',
        'nama': 'Budi Santoso',
        'email': 'budi@gmail.com',
        'no_hp': '081234567890',
        'alamat': 'Jl. Merdeka No. 10',
      };

      final user = UserModel.fromJson(json, explicitActor: 'masyarakat');

      expect(user.id, 'USR-001');
      expect(user.name, 'Budi Santoso');
      expect(user.email, 'budi@gmail.com');
      expect(user.phoneNumber, '081234567890');
      expect(user.address, 'Jl. Merdeka No. 10');
      expect(user.role, 'masyarakat');
      expect(user.roleDisplay, 'Masyarakat');
    });

    test('parses Admin payload correctly', () {
      final json = {
        'id_admin': 'ADM-001',
        'nama_admin': 'Admin Utama',
        'email': 'admin@sigap.go.id',
        'no_hp': '081122334455',
      };

      final user = UserModel.fromJson(json, explicitActor: 'admin');

      expect(user.id, 'ADM-001');
      expect(user.name, 'Admin Utama');
      expect(user.email, 'admin@sigap.go.id');
      expect(user.phoneNumber, '081122334455');
      expect(user.role, 'admin');
      expect(user.roleDisplay, 'Administrator');
    });

    test('parses Ketua Tim payload correctly', () {
      final json = {
        'id_petugas': 'PET-001',
        'nama_petugas': 'Kapten Tim Alpha',
        'email': 'ketua@sigap.go.id',
        'no_hp': '085566778899',
        'alamat': 'Posko Induk',
        'status_petugas': 'aktif',
        'role': 'ketua_tim',
      };

      final user = UserModel.fromJson(json, explicitActor: 'ketua_tim');

      expect(user.id, 'PET-001');
      expect(user.name, 'Kapten Tim Alpha');
      expect(user.email, 'ketua@sigap.go.id');
      expect(user.status, 'aktif');
      expect(user.role, 'ketua_tim');
      expect(user.roleDisplay, 'Ketua Tim');
    });

    test('parses Petugas Lapangan payload correctly', () {
      final json = {
        'id_petugas': 'PET-002',
        'nama_petugas': 'Petugas Armada 1',
        'email': 'petugas@sigap.go.id',
        'no_hp': '087788990011',
        'status_petugas': 'aktif',
        'role': 'petugas',
      };

      final user = UserModel.fromJson(json, explicitActor: 'petugas');

      expect(user.id, 'PET-002');
      expect(user.name, 'Petugas Armada 1');
      expect(user.email, 'petugas@sigap.go.id');
      expect(user.role, 'petugas');
      expect(user.roleDisplay, 'Petugas Lapangan');
    });

    test('toJson produces valid serializable map', () {
      const user = UserModel(
        id: 'USR-001',
        name: 'Test User',
        email: 'test@example.com',
        role: 'masyarakat',
      );

      final json = user.toJson();

      expect(json['id'], 'USR-001');
      expect(json['name'], 'Test User');
      expect(json['email'], 'test@example.com');
      expect(json['role'], 'masyarakat');
    });
  });
}
