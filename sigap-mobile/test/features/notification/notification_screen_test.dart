import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/data/models/notifikasi_model.dart';
import 'package:sigap_mobile/data/repositories/notifikasi_repository.dart';
import 'package:sigap_mobile/features/notifikasi/presentation/notification_list_screen.dart';
import 'package:sigap_mobile/features/notifikasi/presentation/notifikasi_controller.dart';

class MockNotifikasiRepository extends Mock implements NotifikasiRepository {}

void main() {
  late MockNotifikasiRepository mockRepo;
  late NotifikasiController controller;

  setUp(() {
    mockRepo = MockNotifikasiRepository();
    controller = NotifikasiController(repository: mockRepo);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: NotificationListScreen(notifikasiController: controller),
    );
  }

  testWidgets('NotificationListScreen renders empty state', (tester) async {
    when(() => mockRepo.getNotifikasiList()).thenAnswer((_) async => []);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Belum Ada Notifikasi'), findsOneWidget);
  });

  testWidgets('NotificationListScreen renders notifications', (tester) async {
    when(() => mockRepo.getNotifikasiList()).thenAnswer(
      (_) async => [
        const NotifikasiModel(
          idNotifikasi: 'NTF-001',
          type: 'ALARM_CREATED',
          title: 'Laporan Baru',
          message: 'Laporan baru masuk.',
          isRead: false,
        ),
      ],
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Laporan Baru'), findsOneWidget);
    expect(find.text('Laporan baru masuk.'), findsOneWidget);
  });

  testWidgets('NotificationListScreen renders loading state initially', (tester) async {
    final completer = Completer<List<NotifikasiModel>>();
    when(() => mockRepo.getNotifikasiList()).thenAnswer((_) => completer.future);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete([]);
    await tester.pumpAndSettle();
  });
}
