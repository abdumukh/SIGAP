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
import 'package:sigap_mobile/features/penanganan/presentation/dokumentasi_controller.dart';
import 'package:sigap_mobile/features/penanganan/presentation/korban_controller.dart';
import 'package:sigap_mobile/features/penanganan/presentation/logistik_controller.dart';
import 'package:sigap_mobile/features/penanganan/presentation/penanganan_controller.dart';
import 'package:sigap_mobile/features/penanganan/presentation/penanganan_list_screen.dart';

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
    when(() => mockPenangananRepo.getPenangananList()).thenAnswer((_) async => []);
    when(() => mockDokumentasiRepo.getDokumentasiList()).thenAnswer((_) async => []);

    penangananController = PenangananController(repository: mockPenangananRepo);
    dokumentasiController = DokumentasiController(repository: mockDokumentasiRepo);
    korbanController = KorbanController(repository: mockKorbanRepo);
    logistikController = LogistikController(repository: mockLogistikRepo);
    authController = AuthController(repository: mockAuthRepo);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: PenangananListScreen(
        penangananController: penangananController,
        dokumentasiController: dokumentasiController,
        korbanController: korbanController,
        logistikController: logistikController,
        authController: authController,
      ),
    );
  }

  group('PenangananListScreen Tests', () {
    testWidgets('renders filter chips and empty state when no penanganan', (WidgetTester tester) async {
      await authController.checkAuthStatus();
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Verify title & filter chips
      expect(find.text('Penanganan Saya'), findsOneWidget);
      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Menuju Lokasi'), findsOneWidget);
      expect(find.text('Di Lokasi'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);

      // Verify empty state
      expect(find.text('Belum Ada Data Penanganan'), findsOneWidget);
    });

    testWidgets('displays penanganan card when items exist', (WidgetTester tester) async {
      const p1 = PenangananModel(
        idPenanganan: 'PNG-001',
        idAlarm: 'ALM-001',
        idPenugasan: 'TGS-001',
        idPetugas: 'PTG-001',
        statusPenanganan: 'menuju_lokasi',
        alarmJenisDarurat: 'Kebakaran Rumah',
        petugasNama: 'Budi Petugas',
      );

      when(() => mockPenangananRepo.getPenangananList()).thenAnswer((_) async => [p1]);

      await authController.checkAuthStatus();
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('PNG-001'), findsOneWidget);
      expect(find.text('Kebakaran Rumah (ALM-001)'), findsOneWidget);
      expect(find.text('Menuju Lokasi'), findsWidgets);
    });
  });
}
