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
import '../features/penugasan/presentation/create_penugasan_screen.dart';
import '../features/penugasan/presentation/penugasan_controller.dart';
import '../features/penugasan/presentation/penugasan_list_screen.dart';
import '../features/splash/splash_screen.dart';
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

  /// Builds route map injecting shared controllers.
  static Map<String, WidgetBuilder> getRoutes({
    required AuthController authController,
    required AlarmController alarmController,
    required TimController timController,
    required AnggotaTimController anggotaTimController,
    required PenugasanController penugasanController,
  }) {
    return {
      splash: (context) => SplashScreen(authController: authController),
      login: (context) => LoginScreen(authController: authController),
      admin: (context) => AdminDashboardScreen(
            authController: authController,
            alarmController: alarmController,
            timController: timController,
            penugasanController: penugasanController,
          ),
      masyarakat: (context) => MasyarakatDashboardScreen(
            authController: authController,
            alarmController: alarmController,
          ),
      ketuaTim: (context) => KetuaTimDashboardScreen(
            authController: authController,
            alarmController: alarmController,
          ),
      petugas: (context) => PetugasDashboardScreen(
            authController: authController,
            alarmController: alarmController,
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
    };
  }
}
