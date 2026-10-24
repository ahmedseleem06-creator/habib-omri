import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'lock_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkNextScreen();
  }

  Future<void> _checkNextScreen() async {
    await AuthService().init();
    await Future.delayed(const Duration(milliseconds: 2200));

    if (!mounted) return;

    final loggedIn = await AuthService().isLoggedIn();
    if (loggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LockScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glowing Heart Logo
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.primary, Colors.transparent],
                  stops: [0.3, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.5),
                    blurRadius: 35,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.favorite_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 1000.ms),

            const SizedBox(height: 30),

            // App Title
            const Text(
              "عالمنا الخاص",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: AppTheme.textMain,
              ),
            ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3, end: 0),

            const SizedBox(height: 8),

            // Welcome Message
            Text(
              "أهلاً بكم في عالم أحمد ومروة ❤️",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryLight,
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

            const SizedBox(height: 14),

            // Romantic Dedication for Marwa
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated.withOpacity(0.8),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.accentPink.withOpacity(0.4)),
              ),
              child: const Text(
                "بحبك يا مروة وربنا يجعلك حلالي 💍❤️",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFF472B6),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ).animate().fadeIn(delay: 500.ms, duration: 800.ms),
          ],
        ),
      ),
    );
  }
}
