import 'package:flutter/material.dart';
import '../features/alarm/presentation/alarm_controller.dart';
import '../features/alarm/presentation/alarm_list_screen.dart';
import '../features/alarm/presentation/create_alarm_screen.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/dashboard/admin/admin_dashboard_screen.dart';
import '../features/dashboard/ketua_tim/ketua_tim_dashboard_screen.dart';
import '../features/dashboard/masyarakat/masyarakat_dashboard_screen.dart';
import '../features/dashboard/petugas/petugas_dashboard_screen.dart';
import '../features/laporan/presentation/laporan_controller.dart';
import '../features/laporan/presentation/laporan_screen.dart';
import '../features/monitoring/presentation/monitoring_controller.dart';
import '../features/monitoring/presentation/monitoring_screen.dart';
import '../features/notifikasi/presentation/notification_list_screen.dart';
import '../features/notifikasi/presentation/notifikasi_controller.dart';
import '../features/penanganan/presentation/create_penanganan_screen.dart';
import '../features/penanganan/presentation/dokumentasi_controller.dart';
import '../features/penanganan/presentation/penanganan_controller.dart';
import '../features/penanganan/presentation/penanganan_detail_screen.dart';
import '../features/penanganan/presentation/penanganan_list_screen.dart';
import '../features/penugasan/presentation/create_penugasan_screen.dart';
import '../features/penugasan/presentation/penugasan_controller.dart';
import '../features/penugasan/presentation/penugasan_list_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/penanganan/presentation/korban_controller.dart';
import '../features/penanganan/presentation/logistik_controller.dart';
import '../features/tim/presentation/anggota_tim_controller.dart';
import '../features/tim/presentation/tim_controller.dart';
import '../features/tim/presentation/tim_list_screen.dart';

/// Centralized route definitions and route generation for SIGAP.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String admin = '/admin';
  static const String masyarakat = '/masyarakat';
  static const String ketuaTim = '/ketua-tim';
  static const String petugas = '/petugas';

  static const String alarms = '/alarms';
  static const String alarmCreate = '/alarms/create';

  static const String tim = '/tim';
  static const String penugasan = '/penugasan';
  static const String penugasanCreate = '/penugasan/create';

  static const String penanganan = '/penanganan';
  static const String penangananCreate = '/penanganan/create';
  static const String penangananDetail = '/penanganan/detail';

  static const String notifications = '/notifications';

  static const String monitoring = '/monitoring';
  static const String laporan = '/laporan';

  /// Maps backend actor/role string to corresponding route path.
  static String getRouteForActor(String actor) {
    switch (actor.toLowerCase()) {
      case 'admin':
        return admin;
      case 'ketua_tim':
        return ketuaTim;
      case 'petugas':
        return petugas;
      case 'masyarakat':
      default:
        return masyarakat;
    }
  }

  /// Returns allowed laporan types for a given role (Section 12 spec).
  static List<String> getAllowedLaporanTypes(String actor) {
    switch (actor.toLowerCase()) {
      case 'admin':
        return ['alarm', 'penugasan', 'penanganan', 'pengguna', 'petugas'];
      case 'ketua_tim':
        return ['alarm', 'penugasan', 'penanganan', 'petugas'];
      case 'petugas':
        return ['alarm', 'penugasan', 'penanganan'];
      case 'masyarakat':
      default:
        return ['alarm', 'penanganan'];
    }
  }

  /// Returns default laporan type for a given role.
  static String getDefaultLaporanType(String actor) {
    switch (actor.toLowerCase()) {
      case 'admin':
        return 'alarm';
      case 'ketua_tim':
        return 'penugasan';
      case 'petugas':
        return 'alarm';
      case 'masyarakat':
      default:
        return 'alarm';
    }
  }

  /// Builds route map injecting shared controllers.
  static Map<String, WidgetBuilder> getRoutes({
    required AuthController authController,
    required AlarmController alarmController,
    required TimController timController,
    required AnggotaTimController anggotaTimController,
    required PenugasanController penugasanController,
    required PenangananController penangananController,
    required DokumentasiController dokumentasiController,
    required KorbanController korbanController,
    required LogistikController logistikController,
    required NotifikasiController notifikasiController,
    required MonitoringController monitoringController,
    required LaporanController laporanController,
  }) {
    return {
      splash: (context) => SplashScreen(authController: authController),
      login: (context) => LoginScreen(authController: authController),
      admin: (context) => AdminDashboardScreen(
            authController: authController,
            alarmController: alarmController,
            timController: timController,
            penugasanController: penugasanController,
            notifikasiController: notifikasiController,
            monitoringController: monitoringController,
            laporanController: laporanController,
          ),
      masyarakat: (context) => MasyarakatDashboardScreen(
            authController: authController,
            alarmController: alarmController,
            notifikasiController: notifikasiController,
          ),
      ketuaTim: (context) => KetuaTimDashboardScreen(
            authController: authController,
            alarmController: alarmController,
            notifikasiController: notifikasiController,
            monitoringController: monitoringController,
            laporanController: laporanController,
          ),
      petugas: (context) => PetugasDashboardScreen(
            authController: authController,
            alarmController: alarmController,
            notifikasiController: notifikasiController,
            monitoringController: monitoringController,
            laporanController: laporanController,
          ),
      alarms: (context) => AlarmListScreen(
            alarmController: alarmController,
            authController: authController,
          ),
      alarmCreate: (context) => CreateAlarmScreen(
            alarmController: alarmController,
          ),
      tim: (context) => TimListScreen(
            timController: timController,
            anggotaTimController: anggotaTimController,
          ),
      penugasan: (context) => PenugasanListScreen(
            penugasanController: penugasanController,
            authController: authController,
            alarmController: alarmController,
            timController: timController,
            penangananController: penangananController,
            dokumentasiController: dokumentasiController,
            korbanController: korbanController,
            logistikController: logistikController,
          ),
      penugasanCreate: (context) {
        final initialAlarmId =
            ModalRoute.of(context)?.settings.arguments as String?;
        return CreatePenugasanScreen(
          penugasanController: penugasanController,
          alarmController: alarmController,
          timController: timController,
          initialAlarmId: initialAlarmId,
        );
      },
      penanganan: (context) => PenangananListScreen(
            penangananController: penangananController,
            dokumentasiController: dokumentasiController,
            korbanController: korbanController,
            logistikController: logistikController,
            authController: authController,
          ),
      penangananCreate: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        String idPenugasan = '';
        String? alarmJenisDarurat;
        String? idAlarm;

        if (args is String) {
          idPenugasan = args;
        } else if (args is Map<String, dynamic>) {
          idPenugasan = args['idPenugasan'] as String? ?? '';
          alarmJenisDarurat = args['alarmJenisDarurat'] as String?;
          idAlarm = args['idAlarm'] as String?;
        }

        return CreatePenangananScreen(
          idPenugasan: idPenugasan,
          alarmJenisDarurat: alarmJenisDarurat,
          idAlarm: idAlarm,
          penangananController: penangananController,
          dokumentasiController: dokumentasiController,
          korbanController: korbanController,
          logistikController: logistikController,
          authController: authController,
        );
      },
      penangananDetail: (context) {
        final idPenanganan =
            ModalRoute.of(context)?.settings.arguments as String? ?? '';
        return PenangananDetailScreen(
          idPenanganan: idPenanganan,
          penangananController: penangananController,
          dokumentasiController: dokumentasiController,
          korbanController: korbanController,
          logistikController: logistikController,
          authController: authController,
        );
      },
      notifications: (context) => NotificationListScreen(
            notifikasiController: notifikasiController,
          ),
      monitoring: (context) => MonitoringScreen(
            controller: monitoringController,
          ),
      laporan: (context) {
        final role = authController.currentUser?.role ?? 'masyarakat';
        return LaporanScreen(
          controller: laporanController,
          initialType: getDefaultLaporanType(role),
          allowedTypes: getAllowedLaporanTypes(role),
        );
      },
    };
  }
}
