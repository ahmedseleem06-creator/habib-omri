import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set transparent status bar and dark navigation bar for Telegram sleek feel
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.background,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const HabibOmriApp());
}

class HabibOmriApp extends StatelessWidget {
  const HabibOmriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'حبيب عمري',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
