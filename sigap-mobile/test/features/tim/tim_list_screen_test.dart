import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/core/constants/app_theme.dart';
import 'package:sigap_mobile/data/models/tim_model.dart';
import 'package:sigap_mobile/data/repositories/anggota_tim_repository.dart';
import 'package:sigap_mobile/data/repositories/tim_repository.dart';
import 'package:sigap_mobile/features/tim/presentation/anggota_tim_controller.dart';
import 'package:sigap_mobile/features/tim/presentation/tim_controller.dart';
import 'package:sigap_mobile/features/tim/presentation/tim_list_screen.dart';

class MockTimRepository extends Mock implements TimRepository {}
class MockAnggotaTimRepository extends Mock implements AnggotaTimRepository {}

void main() {
  late MockTimRepository mockTimRepo;
  late MockAnggotaTimRepository mockAnggotaRepo;
  late TimController timController;
  late AnggotaTimController anggotaTimController;

  const testTim = TimModel(
    idTim: 'TIM-001',
    namaTim: 'Tim Reaksi Cepat 1',
    statusTim: 'aktif',
  );

  setUp(() {
    mockTimRepo = MockTimRepository();
    mockAnggotaRepo = MockAnggotaTimRepository();
    timController = TimController(repository: mockTimRepo);
    anggotaTimController = AnggotaTimController(repository: mockAnggotaRepo);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: TimListScreen(
        timController: timController,
        anggotaTimController: anggotaTimController,
      ),
    );
  }

  group('TimListScreen Widget Tests', () {
    testWidgets('renders filter chips and empty state when no teams',
        (tester) async {
      when(() => mockTimRepo.getTimList()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Semua Tim'), findsOneWidget);
      expect(find.text('Aktif'), findsOneWidget);
      expect(find.text('Nonaktif'), findsOneWidget);
      expect(find.text('Belum Ada Data Tim'), findsOneWidget);
      expect(find.text('Tambah Tim'), findsOneWidget);
    });

    testWidgets('renders team cards when teams exist', (tester) async {
      when(() => mockTimRepo.getTimList()).thenAnswer((_) async => [testTim]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('TIM-001'), findsOneWidget);
      expect(find.text('Tim Reaksi Cepat 1'), findsOneWidget);
      expect(find.text('Aktif'), findsWidgets);
    });
  });
}
