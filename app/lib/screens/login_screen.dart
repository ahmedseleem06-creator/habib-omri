import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'lock_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final phone = _phoneController.text.trim();
    final pin = _pinController.text.trim();

    if (phone.isEmpty || pin.isEmpty) {
      setState(() {
        _errorMessage = "يرجى كتابة رقم الموبايل والرمز السري";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await AuthService().loginWithServer(phone, pin);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (res["success"] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LockScreen()),
      );
    } else {
      setState(() {
        _errorMessage = res["message"];
      });
    }
  }

  void _showServerSettings() {
    final urlController = TextEditingController(text: AuthService().serverUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        title: const Text("إعدادات رابط السيرفر", style: TextStyle(color: AppTheme.textMain)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "اكتب رابط خادم البايثون (مثلاً سيرفر سحابي أو IP شبكة الواي فاي):",
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.surface,
                hintText: "https://your-server.onrender.com",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              AuthService().updateServerUrl(urlController.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("تم حفظ رابط السيرفر بنجاح")),
              );
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppTheme.textMuted),
            onPressed: _showServerSettings,
            tooltip: "إعدادات السيرفر",
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite, size: 18, color: AppTheme.accentPink),
                      SizedBox(width: 8),
                      Text(
                        "مخصص لشخصين فقط ❤️",
                        style: TextStyle(fontSize: 13, color: AppTheme.primaryLight, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "تسجيل الدخول",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                ),
                const SizedBox(height: 8),
                const Text(
                  "سجّل برقمك للدخول إلى عالمكم الخاص",
                  style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 32),

                // Error alert
                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),

                // Phone Input
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: AppTheme.textMain),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone_android_rounded, color: AppTheme.primaryLight),
                    hintText: "رقم الموبايل",
                    hintStyle: const TextStyle(color: AppTheme.textHint),
                    filled: true,
                    fillColor: AppTheme.surfaceElevated,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // PIN Input
                TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  style: const TextStyle(color: AppTheme.textMain),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.pin_rounded, color: AppTheme.primaryLight),
                    hintText: "الرمز السري (الافتراضي 1234)",
                    hintStyle: const TextStyle(color: AppTheme.textHint),
                    filled: true,
                    fillColor: AppTheme.surfaceElevated,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text(
                            "دخول",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),

                const SizedBox(height: 24),
                // Quick phone fill helper buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        _phoneController.text = "01000000001";
                        _pinController.text = "1234";
                      },
                      child: const Text("تجربة (رقمي)", style: TextStyle(color: AppTheme.primaryLight, fontSize: 13)),
                    ),
                    const Text(" • ", style: TextStyle(color: AppTheme.textHint)),
                    TextButton(
                      onPressed: () {
                        _phoneController.text = "01000000002";
                        _pinController.text = "1234";
                      },
                      child: const Text("تجربة (رقم خطيبتي)", style: TextStyle(color: AppTheme.accentPink, fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
