import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/core/constants/app_theme.dart';
import 'package:sigap_mobile/data/repositories/auth_repository.dart';
import 'package:sigap_mobile/features/auth/presentation/auth_controller.dart';
import 'package:sigap_mobile/features/auth/presentation/login_screen.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late AuthController authController;

  setUp(() {
    mockRepository = MockAuthRepository();
    authController = AuthController(repository: mockRepository);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: LoginScreen(authController: authController),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('renders all essential login elements', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('SIGAP'), findsOneWidget);
      expect(find.text('Masuk ke Akun Anda'), findsOneWidget);
      expect(find.text('Alamat Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('MASUK'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('shows validation errors when submitting empty form', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final loginButton = find.text('MASUK');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(find.text('Email wajib diisi'), findsOneWidget);
      expect(find.text('Password wajib diisi'), findsOneWidget);
    });

    testWidgets('tapping sample chips fills email and password fields', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final adminChip = find.text('Admin');
      expect(adminChip, findsOneWidget);

      await tester.ensureVisible(adminChip);
      await tester.pumpAndSettle();

      await tester.tap(adminChip);
      await tester.pumpAndSettle();

      expect(find.text('admin@sigap.go.id'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });
  });
}
