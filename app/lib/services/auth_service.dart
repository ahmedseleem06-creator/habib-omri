import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();

  // Change this to your deployed server URL (or local Wi-Fi IP for testing)
  String serverUrl = "http://10.0.2.2:8000"; 

  // Keys
  static const String keyLoggedIn = "is_logged_in";
  static const String keyUserPhone = "user_phone";
  static const String keyUserName = "user_name";
  static const String keyPartnerPhone = "partner_phone";
  static const String keyPartnerName = "partner_name";
  static const String keyAppPin = "app_lock_pin";
  static const String keyBiometricsEnabled = "biometrics_enabled";
  static const String keyServerUrl = "custom_server_url";

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString(keyServerUrl);
    if (savedUrl != null && savedUrl.isNotEmpty) {
      serverUrl = savedUrl;
    }
  }

  Future<void> updateServerUrl(String url) async {
    serverUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyServerUrl, url);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyLoggedIn) ?? false;
  }

  Future<String?> getUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserPhone);
  }

  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserName) ?? "أنا";
  }

  Future<String> getPartnerName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyPartnerName) ?? "حبيبتي";
  }

  // -----------------------------------------------------------
  // Login with Server
  // -----------------------------------------------------------
  Future<Map<String, dynamic>> loginWithServer(String phone, String pin) async {
    try {
      final response = await http.post(
        Uri.parse("$serverUrl/api/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone, "pin": pin}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        
        await prefs.setBool(keyLoggedIn, true);
        await prefs.setString(keyUserPhone, data["user"]["phone"]);
        await prefs.setString(keyUserName, data["user"]["name"]);
        await prefs.setString(keyPartnerPhone, data["partner"]["phone"]);
        await prefs.setString(keyPartnerName, data["partner"]["name"]);
        
        // Save initial PIN for local lock screen
        if (prefs.getString(keyAppPin) == null) {
          await prefs.setString(keyAppPin, pin);
        }

        return {"success": true, "data": data};
      } else {
        final err = jsonDecode(response.body);
        return {"success": false, "message": err["detail"] ?? "فشل تسجيل الدخول"};
      }
    } catch (e) {
      return {"success": false, "message": "تعذر الاتصال بالسيرفر. تأكد من عمل السيرفر والإنترنت ($e)"};
    }
  }

  // -----------------------------------------------------------
  // Biometrics & PIN Lock
  // -----------------------------------------------------------
  Future<bool> canUseBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> authenticateBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'يرجى تأكيد بصمة الإصبع لفتح تطبيق حبيب عمري ❤️',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyPin(String enteredPin) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString(keyAppPin) ?? "1234";
    return enteredPin == savedPin;
  }

  Future<void> setAppPin(String newPin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyAppPin, newPin);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyLoggedIn, false);
  }
}
