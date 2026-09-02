import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/data/models/anggota_tim_model.dart';
import 'package:sigap_mobile/data/models/tim_model.dart';
import 'package:sigap_mobile/data/repositories/anggota_tim_repository.dart';
import 'package:sigap_mobile/data/repositories/tim_repository.dart';
import 'package:sigap_mobile/features/tim/presentation/anggota_tim_controller.dart';
import 'package:sigap_mobile/features/tim/presentation/tim_controller.dart';
import 'package:sigap_mobile/features/tim/presentation/tim_detail_screen.dart';

class MockTimRepository extends Mock implements TimRepository {}

class MockAnggotaTimRepository extends Mock implements AnggotaTimRepository {}

void main() {
  late MockTimRepository mockTimRepository;
  late MockAnggotaTimRepository mockAnggotaRepository;
  late TimController timController;
  late AnggotaTimController anggotaTimController;

  setUp(() {
    mockTimRepository = MockTimRepository();
    mockAnggotaRepository = MockAnggotaTimRepository();
    timController = TimController(repository: mockTimRepository);
    anggotaTimController =
        AnggotaTimController(repository: mockAnggotaRepository);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: TimDetailScreen(
        idTim: 'TIM-001',
        timController: timController,
        anggotaTimController: anggotaTimController,
      ),
    );
  }

  testWidgets('TimDetailScreen renders team header and members correctly',
      (tester) async {
    const testTim = TimModel(
      idTim: 'TIM-001',
      namaTim: 'Tim Reaksi Cepat 1',
      note: 'Wilayah Jakarta',
      statusTim: 'aktif',
    );

    const testMembers = [
      AnggotaTimModel(
        idAnggotaTim: 'AGT-001',
        idTim: 'TIM-001',
        idPetugas: 'PTG-001',
        namaPetugas: 'Ahmad Ketua',
        role: 'ketua_tim',
        statusAnggota: 'aktif',
      ),
    ];

    when(() => mockTimRepository.getTimById('TIM-001'))
        .thenAnswer((_) async => testTim);
    when(() => mockAnggotaRepository.getAnggota('TIM-001'))
        .thenAnswer((_) async => testMembers);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Detail Tim'), findsOneWidget);
    expect(find.text('Tim Reaksi Cepat 1'), findsOneWidget);
    expect(find.text('Wilayah Jakarta'), findsOneWidget);
    expect(find.text('Daftar Anggota Tim'), findsOneWidget);
    expect(find.text('Ahmad Ketua'), findsOneWidget);
    expect(find.text('Ketua Tim'), findsOneWidget);
  });
}
