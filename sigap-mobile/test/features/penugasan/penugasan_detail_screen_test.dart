import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/data/models/penanganan_model.dart';
import 'package:sigap_mobile/data/models/penugasan_model.dart';
import 'package:sigap_mobile/data/models/user_model.dart';
import 'package:sigap_mobile/data/repositories/dokumentasi_repository.dart';
import 'package:sigap_mobile/data/repositories/penanganan_repository.dart';
import 'package:sigap_mobile/data/repositories/penugasan_repository.dart';
import 'package:sigap_mobile/features/auth/presentation/auth_controller.dart';
import 'package:sigap_mobile/features/penanganan/presentation/dokumentasi_controller.dart';
import 'package:sigap_mobile/features/penanganan/presentation/penanganan_controller.dart';
import 'package:sigap_mobile/features/penugasan/presentation/penugasan_controller.dart';
import 'package:sigap_mobile/features/penugasan/presentation/penugasan_detail_screen.dart';

class MockPenugasanRepository extends Mock implements PenugasanRepository {}
class MockPenangananRepository extends Mock implements PenangananRepository {}
class MockDokumentasiRepository extends Mock implements DokumentasiRepository {}
class MockAuthController extends Mock implements AuthController {}

void main() {
  late MockPenugasanRepository mockPenugasanRepo;
  late MockPenangananRepository mockPenangananRepo;
  late MockDokumentasiRepository mockDokumentasiRepo;
  late MockAuthController mockAuth;
  late PenugasanController penugasanController;
  late PenangananController penangananController;
  late DokumentasiController dokumentasiController;

  setUp(() {
    mockPenugasanRepo = MockPenugasanRepository();
    mockPenangananRepo = MockPenangananRepository();
    mockDokumentasiRepo = MockDokumentasiRepository();
    mockAuth = MockAuthController();
    penugasanController = PenugasanController(repository: mockPenugasanRepo);
    penangananController = PenangananController(repository: mockPenangananRepo);
    dokumentasiController = DokumentasiController(repository: mockDokumentasiRepo);

    when(() => mockAuth.currentUser).thenReturn(
      const UserModel(
        id: 'PTG-001',
        name: 'Petugas Test',
        email: 'petugas@sigap.id',
        role: 'petugas',
      ),
    );
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: PenugasanDetailScreen(
        idPenugasan: 'TGS-001',
        penugasanController: penugasanController,
      ),
    );
  }

  testWidgets('PenugasanDetailScreen renders assignment details and sections',
      (tester) async {
    const testPenugasan = PenugasanModel(
      idPenugasan: 'TGS-001',
      idAlarm: 'ALM-001',
      idTim: 'TIM-001',
      idKetuaTim: 'PTG-001',
      idPetugasArmada: 'PTG-002',
      idArmada: 'ARM-001',
      statusPenugasan: 'menunggu',
      note: 'Bawa peralatan hidrolik',
      alarmJenisDarurat: 'Kecelakaan Lalu Lintas',
      alarmStatus: 'diverifikasi',
      alarmLatitude: -6.2,
      alarmLongitude: 106.8,
      timNama: 'Tim Reaksi Cepat 1',
      timStatus: 'aktif',
      ketuaTimNama: 'Ahmad Ketua',
      petugasArmadaNama: 'Doni Driver',
      armadaNama: 'Ambulans 01',
      armadaJenis: 'Ambulans',
      armadaNomor: 'B 9999 XX',
      armadaStatus: 'digunakan',
    );

    when(() => mockPenugasanRepo.getPenugasanById('TGS-001'))
        .thenAnswer((_) async => testPenugasan);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Detail Penugasan'), findsOneWidget);
    expect(find.text('TGS-001'), findsOneWidget);
    expect(find.text('ALM-001'), findsOneWidget);
    expect(find.text('Kecelakaan Lalu Lintas'), findsNWidgets(2));
    expect(find.text('Informasi Alarm Darurat'), findsOneWidget);
    expect(find.text('Tim yang Ditugaskan'), findsOneWidget);
    expect(find.text('Tim Reaksi Cepat 1'), findsOneWidget);
    expect(find.text('Personel'), findsOneWidget);
    expect(find.text('Ahmad Ketua (PTG-001)'), findsOneWidget);
    expect(find.text('Armada Kendaraan'), findsOneWidget);
    expect(find.text('Ambulans 01'), findsOneWidget);
    expect(find.text('B 9999 XX'), findsOneWidget);
    expect(find.text('Instruksi & Catatan'), findsOneWidget);
    expect(find.text('Bawa peralatan hidrolik'), findsOneWidget);
  });

  testWidgets('shows LIHAT PENANGANAN when penanganan already exists for penugasan',
      (tester) async {
    const testPenugasan = PenugasanModel(
      idPenugasan: 'TGS-001',
      idAlarm: 'ALM-001',
      idTim: 'TIM-001',
      idKetuaTim: 'PTG-001',
      statusPenugasan: 'berangkat',
      alarmJenisDarurat: 'Kebakaran',
    );

    when(() => mockPenugasanRepo.getPenugasanById('TGS-001'))
        .thenAnswer((_) async => testPenugasan);
    when(() => mockPenangananRepo.getPenangananList()).thenAnswer(
      (_) async => [
        const PenangananModel(
          idPenanganan: 'PNG-001',
          idAlarm: 'ALM-001',
          idPenugasan: 'TGS-001',
          idPetugas: 'PTG-001',
          statusPenanganan: 'di_lokasi',
        ),
      ],
    );

    await penangananController.fetchPenangananList();

    await tester.pumpWidget(
      MaterialApp(
        home: PenugasanDetailScreen(
          idPenugasan: 'TGS-001',
          penugasanController: penugasanController,
          authController: mockAuth,
          penangananController: penangananController,
          dokumentasiController: dokumentasiController,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('LIHAT PENANGANAN'), findsOneWidget);
    expect(find.text('MULAI PENANGANAN'), findsNothing);
  });
}
