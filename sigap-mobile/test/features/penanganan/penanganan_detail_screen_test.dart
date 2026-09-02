import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/data/models/dokumentasi_model.dart';
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
import 'package:sigap_mobile/features/penanganan/presentation/penanganan_detail_screen.dart';

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

  const samplePenangananMenuju = PenangananModel(
    idPenanganan: 'PNG-001',
    idAlarm: 'ALM-001',
    idPenugasan: 'TGS-001',
    idPetugas: 'PTG-001',
    statusPenanganan: 'menuju_lokasi',
    waktuBerangkat: '2026-08-20T10:00:00Z',
    alarmJenisDarurat: 'Kebakaran Pabrik',
    alarmStatus: 'diverifikasi',
    alarmLatitude: -6.2088,
    alarmLongitude: 106.8456,
  );

  const samplePenangananDiLokasi = PenangananModel(
    idPenanganan: 'PNG-001',
    idAlarm: 'ALM-001',
    idPenugasan: 'TGS-001',
    idPetugas: 'PTG-001',
    statusPenanganan: 'di_lokasi',
    waktuBerangkat: '2026-08-20T10:00:00Z',
    waktuTiba: '2026-08-20T10:15:00Z',
    alarmJenisDarurat: 'Kebakaran Pabrik',
  );

  const samplePenangananSelesai = PenangananModel(
    idPenanganan: 'PNG-001',
    idAlarm: 'ALM-001',
    idPenugasan: 'TGS-001',
    idPetugas: 'PTG-001',
    statusPenanganan: 'selesai',
    waktuBerangkat: '2026-08-20T10:00:00Z',
    waktuTiba: '2026-08-20T10:15:00Z',
    waktuSelesai: '2026-08-20T11:00:00Z',
    alarmJenisDarurat: 'Kebakaran Pabrik',
  );

  setUp(() {
    mockPenangananRepo = MockPenangananRepository();
    mockDokumentasiRepo = MockDokumentasiRepository();
    mockAuthRepo = MockAuthRepository();
    mockKorbanRepo = MockKorbanRepository();
    mockLogistikRepo = MockLogistikRepository();

    when(() => mockAuthRepo.getCurrentUser()).thenAnswer((_) async => samplePetugas);
    when(() => mockDokumentasiRepo.getDokumentasiList()).thenAnswer((_) async => []);
    when(() => mockKorbanRepo.getKorbanList()).thenAnswer((_) async => []);
    when(() => mockLogistikRepo.getLogistikList()).thenAnswer((_) async => []);

    penangananController = PenangananController(repository: mockPenangananRepo);
    dokumentasiController = DokumentasiController(repository: mockDokumentasiRepo);
    korbanController = KorbanController(repository: mockKorbanRepo);
    logistikController = LogistikController(repository: mockLogistikRepo);
    authController = AuthController(repository: mockAuthRepo);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: PenangananDetailScreen(
        idPenanganan: 'PNG-001',
        penangananController: penangananController,
        dokumentasiController: dokumentasiController,
        korbanController: korbanController,
        logistikController: logistikController,
        authController: authController,
      ),
    );
  }

  group('PenangananDetailScreen Tests', () {
    testWidgets('renders details and SUDAH TIBA DI LOKASI button when menuju_lokasi', (WidgetTester tester) async {
      when(() => mockPenangananRepo.getPenangananById('PNG-001'))
          .thenAnswer((_) async => samplePenangananMenuju);

      await authController.checkAuthStatus();
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Detail Penanganan Lapangan'), findsOneWidget);
      expect(find.text('PNG-001'), findsOneWidget);
      expect(find.text('Kebakaran Pabrik'), findsWidgets);
      expect(find.text('Tahapan Penanganan Lapangan'), findsOneWidget);

      // Verify Action button
      expect(find.text('SUDAH TIBA DI LOKASI'), findsOneWidget);
      expect(find.text('SELESAIKAN PENANGANAN'), findsNothing);
    });

    testWidgets('renders SELESAIKAN PENANGANAN button when di_lokasi', (WidgetTester tester) async {
      when(() => mockPenangananRepo.getPenangananById('PNG-001'))
          .thenAnswer((_) async => samplePenangananDiLokasi);

      await authController.checkAuthStatus();
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('SELESAIKAN PENANGANAN'), findsOneWidget);
      expect(find.text('SUDAH TIBA DI LOKASI'), findsNothing);
    });

    testWidgets('renders completion banner and no action buttons when selesai', (WidgetTester tester) async {
      when(() => mockPenangananRepo.getPenangananById('PNG-001'))
          .thenAnswer((_) async => samplePenangananSelesai);

      await authController.checkAuthStatus();
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Penanganan ini telah selesai dan ditutup secara resmi.'), findsOneWidget);
      expect(find.text('SUDAH TIBA DI LOKASI'), findsNothing);
      expect(find.text('SELESAIKAN PENANGANAN'), findsNothing);
    });

    testWidgets('displays field documentation items', (WidgetTester tester) async {
      const doc = DokumentasiModel(
        idDokumentasi: 'DOC-001',
        idPenanganan: 'PNG-001',
        idPetugas: 'PTG-001',
        jenisDokumentasi: 'foto',
        fileDokumentasi: 'dokumentasi/foto_kebakaran.jpg',
        waktuUpload: '2026-08-20T10:30:00Z',
        petugasNama: 'Budi Petugas',
      );

      when(() => mockPenangananRepo.getPenangananById('PNG-001'))
          .thenAnswer((_) async => samplePenangananMenuju);
      when(() => mockDokumentasiRepo.getDokumentasiList())
          .thenAnswer((_) async => [doc]);

      await authController.checkAuthStatus();
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Dokumentasi Lapangan'), findsOneWidget);
      expect(find.text('foto_kebakaran.jpg'), findsOneWidget);
      expect(find.text('FOTO'), findsOneWidget);
    });
  });
}
