import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/core/storage/auth_storage.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late AuthStorage authStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    authStorage = AuthStorage(storage: mockStorage);
  });

  group('AuthStorage Tests', () {
    test('saveToken writes token with correct key', () async {
      when(() => mockStorage.write(key: 'sigap_auth_token', value: 'sample_token_123'))
          .thenAnswer((_) async => {});

      await authStorage.saveToken('sample_token_123');

      verify(() => mockStorage.write(key: 'sigap_auth_token', value: 'sample_token_123')).called(1);
    });

    test('getToken returns token from storage', () async {
      when(() => mockStorage.read(key: 'sigap_auth_token'))
          .thenAnswer((_) async => 'sample_token_123');

      final token = await authStorage.getToken();

      expect(token, 'sample_token_123');
      verify(() => mockStorage.read(key: 'sigap_auth_token')).called(1);
    });

    test('hasToken returns true when token is present and non-empty', () async {
      when(() => mockStorage.read(key: 'sigap_auth_token'))
          .thenAnswer((_) async => 'valid_token');

      final exists = await authStorage.hasToken();

      expect(exists, isTrue);
    });

    test('hasToken returns false when token is null or whitespace', () async {
      when(() => mockStorage.read(key: 'sigap_auth_token'))
          .thenAnswer((_) async => null);

      final exists = await authStorage.hasToken();

      expect(exists, isFalse);
    });

    test('deleteToken removes token from storage', () async {
      when(() => mockStorage.delete(key: 'sigap_auth_token'))
          .thenAnswer((_) async => {});

      await authStorage.deleteToken();

      verify(() => mockStorage.delete(key: 'sigap_auth_token')).called(1);
    });

    test('saveActor and getActor work as expected', () async {
      when(() => mockStorage.write(key: 'sigap_auth_actor', value: 'petugas'))
          .thenAnswer((_) async => {});
      when(() => mockStorage.read(key: 'sigap_auth_actor'))
          .thenAnswer((_) async => 'petugas');

      await authStorage.saveActor('petugas');
      final actor = await authStorage.getActor();

      expect(actor, 'petugas');
      verify(() => mockStorage.write(key: 'sigap_auth_actor', value: 'petugas')).called(1);
      verify(() => mockStorage.read(key: 'sigap_auth_actor')).called(1);
    });

    test('clearAll removes token, actor, and user from storage', () async {
      when(() => mockStorage.delete(key: 'sigap_auth_token')).thenAnswer((_) async => {});
      when(() => mockStorage.delete(key: 'sigap_auth_actor')).thenAnswer((_) async => {});
      when(() => mockStorage.delete(key: 'sigap_auth_user')).thenAnswer((_) async => {});

      await authStorage.clearAll();

      verify(() => mockStorage.delete(key: 'sigap_auth_token')).called(1);
      verify(() => mockStorage.delete(key: 'sigap_auth_actor')).called(1);
      verify(() => mockStorage.delete(key: 'sigap_auth_user')).called(1);
    });
  });
}
