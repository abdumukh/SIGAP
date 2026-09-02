import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sigap_mobile/data/repositories/logistik_repository.dart';
import 'package:sigap_mobile/data/services/logistik_service.dart';

class MockLogistikService extends Mock implements LogistikService {}

void main() {
  late MockLogistikService mockService;
  late LogistikRepository repository;

  setUp(() {
    mockService = MockLogistikService();
    repository = LogistikRepository(service: mockService);
  });

  group('LogistikRepository Tests', () {
    final sampleLogistikMap = {
      'id_logistik': 'LOG-001',
      'id_penanganan': 'PNG-001',
      'nama_logistik': 'Selang Pemadam',
      'jumlah': 4,
      'satuan': 'Unit',
      'kondisi': 'Baik',
    };

    test('getLogistikList returns parsed list', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/logistik'),
        data: {
          'status': 'success',
          'data': [sampleLogistikMap],
        },
      );

      when(() => mockService.getLogistikList())
          .thenAnswer((_) async => response);

      final list = await repository.getLogistikList();

      expect(list.length, 1);
      expect(list.first.idLogistik, 'LOG-001');
      expect(list.first.namaLogistik, 'Selang Pemadam');
      expect(list.first.jumlah, 4);
    });

    test('getLogistikById returns single LogistikModel', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/logistik/LOG-001'),
        data: {
          'status': 'success',
          'data': sampleLogistikMap,
        },
      );

      when(() => mockService.getLogistikById('LOG-001'))
          .thenAnswer((_) async => response);

      final logistik = await repository.getLogistikById('LOG-001');

      expect(logistik.idLogistik, 'LOG-001');
      expect(logistik.idPenanganan, 'PNG-001');
    });

    test('createLogistik posts data and returns created model', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/logistik'),
        data: {
          'status': 'success',
          'data': sampleLogistikMap,
        },
      );

      when(() => mockService.createLogistik(any()))
          .thenAnswer((_) async => response);

      final created = await repository.createLogistik(
        idPenanganan: 'PNG-001',
        namaLogistik: 'Selang Pemadam',
        jumlah: 4,
        satuan: 'Unit',
        kondisi: 'Baik',
        note: 'Untuk memadamkan api',
      );

      expect(created.idLogistik, 'LOG-001');
      verify(() => mockService.createLogistik(any())).called(1);
    });

    test('deleteLogistik sends delete request and returns true on success', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/logistik/LOG-001'),
        data: {
          'status': 'success',
          'message': 'Data logistik berhasil dihapus',
        },
      );

      when(() => mockService.deleteLogistik('LOG-001'))
          .thenAnswer((_) async => response);

      final success = await repository.deleteLogistik('LOG-001');

      expect(success, isTrue);
      verify(() => mockService.deleteLogistik('LOG-001')).called(1);
    });
  });
}