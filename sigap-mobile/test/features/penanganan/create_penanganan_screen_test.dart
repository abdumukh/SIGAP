import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/data/models/penanganan_model.dart';
import 'package:sigap_mobile/data/models/user_model.dart';
import 'package:sigap_mobile/data/repositories/auth_repository.dart';
import 'package:sigap_mobile/data/repositories/dokumentasi_repository.dart';
import 'package:sigap_mobile/data/repositories/korban_repository.dart';
import 'package:sigap_mobile/data/repositories/logistik_repository.dart';
import 'package:sigap_mobile/data/repositories/penanganan_repository.dart';
import 'package:sigap_mobile/features/auth/presentation/auth_controller.dart';
import 'package:sigap_mobile/features/penanganan/presentation/create_penanganan_screen.dart';
import 'package:sigap_mobile/features/penanganan/presentation/dokumentasi_controller.dart';
import 'package:sigap_mobile/features/penanganan/presentation/korban_controller.dart';
import 'package:sigap_mobile/features/penanganan/presentation/logistik_controller.dart';
import 'package:sigap_mobile/features/penanganan/presentation/penanganan_controller.dart';

class MockPenangananRepository extends Mock implements PenangananRepository {}
class MockDokumentasiRepository extends Mock implements DokumentasiRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}
class MockKorbanRepository extends Mock implements KorbanRepository {}
class MockLogistikRepository extends Mock implements LogistikRepository {}

void main() {
  late MockPenangananRepository mockPenangananRepo;
  late MockDokumentasiRepository mockDokumentasiRepo;
  late MockAuthRepository mockAuthRepo;
  late MockKorbanRepository mockKorbanRepo;
  late MockLogistikRepository mockLogistikRepo;
  late PenangananController penangananController;
  late DokumentasiController dokumentasiController;
  late KorbanController korbanController;
  late LogistikController logistikController;
  late AuthController authController;

  const samplePetugas = UserModel(
    id: 'PTG-001',
    name: 'Budi Petugas',
    email: 'petugas@sigap.id',
    role: 'petugas',
  );

  setUp(() {
    mockPenangananRepo = MockPenangananRepository();
    mockDokumentasiRepo = MockDokumentasiRepository();
    mockAuthRepo = MockAuthRepository();
    mockKorbanRepo = MockKorbanRepository();
    mockLogistikRepo = MockLogistikRepository();

    when(() => mockAuthRepo.getCurrentUser()).thenAnswer((_) async => samplePetugas);

    penangananController = PenangananController(repository: mockPenangananRepo);
    dokumentasiController = DokumentasiController(repository: mockDokumentasiRepo);
    korbanController = KorbanController(repository: mockKorbanRepo);
    logistikController = LogistikController(repository: mockLogistikRepo);
    authController = AuthController(repository: mockAuthRepo);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: CreatePenangananScreen(
        idPenugasan: 'TGS-001',
        idAlarm: 'ALM-001',
        alarmJenisDarurat: 'Kebakaran Toko',
        penangananController: penangananController,
        dokumentasiController: dokumentasiController,
        korbanController: korbanController,
        logistikController: logistikController,
        authController: authController,
      ),
    );
  }

  group('CreatePenangananScreen Tests', () {
    testWidgets('renders all essential elements and form fields', (WidgetTester tester) async {
      await authController.checkAuthStatus();
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Mulai Penanganan Lapangan'), findsOneWidget);
      expect(find.text('Konfirmasi Keberangkatan'), findsOneWidget);
      expect(find.text('TGS-001'), findsOneWidget);
      expect(find.text('ALM-001'), findsOneWidget);
      expect(find.text('Kebakaran Toko'), findsOneWidget);
      expect(find.text('MULAI PENANGANAN'), findsOneWidget);
    });

    testWidgets('submitting creates penanganan with idPenugasan and note', (WidgetTester tester) async {
      const createdModel = PenangananModel(
        idPenanganan: 'PNG-001',
        idAlarm: 'ALM-001',
        idPenugasan: 'TGS-001',
        idPetugas: 'PTG-001',
        statusPenanganan: 'menuju_lokasi',
      );

      when(() => mockPenangananRepo.createPenanganan(
            idPenugasan: 'TGS-001',
            note: any(named: 'note'),
          )).thenAnswer((_) async => createdModel);
      when(() => mockPenangananRepo.getPenangananById('PNG-001'))
          .thenAnswer((_) async => createdModel);
      when(() => mockDokumentasiRepo.getDokumentasiList())
          .thenAnswer((_) async => []);

      await authController.checkAuthStatus();
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Enter optional note
      await tester.enterText(find.byType(TextFormField), 'Rute via jalan tol');
      await tester.pump();

      // Tap Mulai Penanganan
      await tester.tap(find.text('MULAI PENANGANAN'));
      await tester.pumpAndSettle();

      verify(() => mockPenangananRepo.createPenanganan(
            idPenugasan: 'TGS-001',
            note: 'Rute via jalan tol',
          )).called(1);
    });
  });
}
