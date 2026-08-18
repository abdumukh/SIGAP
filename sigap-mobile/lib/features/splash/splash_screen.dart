import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../routes/app_routes.dart';
import '../auth/presentation/auth_controller.dart';

/// Splash Screen that boots the application and resolves initial authentication state.
class SplashScreen extends StatefulWidget {
  final AuthController authController;

  const SplashScreen({
    super.key,
    required this.authController,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Artificial minimum delay for smooth splash UX (800ms)
    await Future.wait([
      widget.authController.checkAuthStatus(),
      Future.delayed(const Duration(milliseconds: 800)),
    ]);

    if (!mounted) return;

    if (widget.authController.isAuthenticated && widget.authController.currentUser != null) {
      final role = widget.authController.currentUser!.role;
      final targetRoute = AppRoutes.getRouteForActor(role);
      Navigator.of(context).pushReplacementNamed(targetRoute);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.emergencyRed,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_hospital_rounded,
                size: 52,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'SIGAP',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sistem Informasi Gawat Darurat',
              style: TextStyle(
                color: Colors.white.withAlpha(200),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
