import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/core/network/api_exceptions.dart';
import 'package:sigap_mobile/core/storage/auth_storage.dart';
import 'package:sigap_mobile/data/models/auth_response_model.dart';
import 'package:sigap_mobile/data/models/user_model.dart';
import 'package:sigap_mobile/data/repositories/auth_repository.dart';
import 'package:sigap_mobile/data/services/auth_service.dart';

class MockAuthService extends Mock implements AuthService {}
class MockAuthStorage extends Mock implements AuthStorage {}

void main() {
  late MockAuthService mockService;
  late MockAuthStorage mockStorage;
  late AuthRepository repository;

  setUp(() {
    mockService = MockAuthService();
    mockStorage = MockAuthStorage();
    repository = AuthRepository(service: mockService, storage: mockStorage);
  });

  group('AuthRepository Tests', () {
    const testUser = UserModel(
      id: 'USR-001',
      name: 'Masyarakat Test',
      email: 'masyarakat@sigap.go.id',
      role: 'masyarakat',
    );

    const testResponse = AuthResponseModel(
      status: 'success',
      message: 'Login berhasil',
      token: '1|test_token',
      tokenType: 'Bearer',
      actor: 'masyarakat',
      user: testUser,
    );

    test('login saves token and returns user on success', () async {
      when(() => mockService.login(email: 'masyarakat@sigap.go.id', password: 'password123'))
          .thenAnswer((_) async => testResponse);
      when(() => mockStorage.saveToken('1|test_token')).thenAnswer((_) async => {});
      when(() => mockStorage.saveActor('masyarakat')).thenAnswer((_) async => {});
      when(() => mockStorage.saveUserData(any())).thenAnswer((_) async => {});

      final user = await repository.login(
        email: 'masyarakat@sigap.go.id',
        password: 'password123',
      );

      expect(user.id, 'USR-001');
      expect(user.role, 'masyarakat');
      verify(() => mockStorage.saveToken('1|test_token')).called(1);
      verify(() => mockStorage.saveActor('masyarakat')).called(1);
    });

    test('getCurrentUser returns user when token is valid', () async {
      when(() => mockStorage.hasToken()).thenAnswer((_) async => true);
      when(() => mockService.getProfile()).thenAnswer((_) async => testResponse);
      when(() => mockStorage.saveActor('masyarakat')).thenAnswer((_) async => {});
      when(() => mockStorage.saveUserData(any())).thenAnswer((_) async => {});

      final user = await repository.getCurrentUser();

      expect(user, isNotNull);
      expect(user!.email, 'masyarakat@sigap.go.id');
    });

    test('getCurrentUser clears storage and returns null on UnauthorizedException (401)', () async {
      when(() => mockStorage.hasToken()).thenAnswer((_) async => true);
      when(() => mockService.getProfile()).thenThrow(const UnauthorizedException());
      when(() => mockStorage.clearAll()).thenAnswer((_) async => {});

      final user = await repository.getCurrentUser();

      expect(user, isNull);
      verify(() => mockStorage.clearAll()).called(1);
    });

    test('getCurrentUser returns null if no token is stored', () async {
      when(() => mockStorage.hasToken()).thenAnswer((_) async => false);

      final user = await repository.getCurrentUser();

      expect(user, isNull);
      verifyNever(() => mockService.getProfile());
    });

    test('logout calls service and clears storage', () async {
      when(() => mockService.logout()).thenAnswer((_) async => {});
      when(() => mockStorage.clearAll()).thenAnswer((_) async => {});

      await repository.logout();

      verify(() => mockService.logout()).called(1);
      verify(() => mockStorage.clearAll()).called(1);
    });
  });
}
