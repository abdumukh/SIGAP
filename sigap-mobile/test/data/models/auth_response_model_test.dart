import 'package:flutter_test/flutter_test.dart';
import 'package:sigap_mobile/data/models/auth_response_model.dart';

void main() {
  group('AuthResponseModel Tests', () {
    test('parses login response with Sanctum token correctly', () {
      final json = {
        'status': 'success',
        'message': 'Login berhasil',
        'data': {
          'token': '1|sanctum_plain_text_token_abc123',
          'token_type': 'Bearer',
          'actor': 'admin',
          'user': {
            'id_admin': 'ADM-001',
            'nama_admin': 'Administrator',
            'email': 'admin@sigap.go.id',
            'no_hp': '0811223344',
          },
        },
      };

      final authResponse = AuthResponseModel.fromJson(json);

      expect(authResponse.status, 'success');
      expect(authResponse.message, 'Login berhasil');
      expect(authResponse.token, '1|sanctum_plain_text_token_abc123');
      expect(authResponse.tokenType, 'Bearer');
      expect(authResponse.actor, 'admin');
      expect(authResponse.user.id, 'ADM-001');
      expect(authResponse.user.name, 'Administrator');
      expect(authResponse.user.email, 'admin@sigap.go.id');
      expect(authResponse.user.role, 'admin');
    });

    test('parses /api/auth/me response without token correctly', () {
      final json = {
        'status': 'success',
        'message': 'Authenticated user',
        'data': {
          'actor': 'petugas',
          'user': {
            'id_petugas': 'PET-005',
            'nama_petugas': 'Bambang',
            'email': 'petugas5@sigap.go.id',
            'no_hp': '0855667788',
            'status_petugas': 'aktif',
            'role': 'petugas',
          },
        },
      };

      final authResponse = AuthResponseModel.fromJson(json);

      expect(authResponse.status, 'success');
      expect(authResponse.token, isNull);
      expect(authResponse.actor, 'petugas');
      expect(authResponse.user.id, 'PET-005');
      expect(authResponse.user.role, 'petugas');
    });
  });
}
