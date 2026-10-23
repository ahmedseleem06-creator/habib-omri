import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'chat_screen.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _enteredPin = "";
  bool _isError = false;
  String _partnerName = "حبيبتي";

  @override
  void initState() {
    super.initState();
    _loadPartner();
    // Automatically trigger fingerprint prompt on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _promptBiometrics();
    });
  }

  Future<void> _loadPartner() async {
    final name = await AuthService().getPartnerName();
    if (mounted) {
      setState(() {
        _partnerName = name;
      });
    }
  }

  Future<void> _promptBiometrics() async {
    final canAuth = await AuthService().canUseBiometrics();
    if (canAuth) {
      final success = await AuthService().authenticateBiometrics();
      if (success && mounted) {
        _unlockSuccess();
      }
    }
  }

  void _onDigitPress(String digit) {
    if (_enteredPin.length < 4) {
      setState(() {
        _isError = false;
        _enteredPin += digit;
      });

      if (_enteredPin.length == 4) {
        _verifyEnteredPin();
      }
    }
  }

  void _onDelete() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _isError = false;
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  Future<void> _verifyEnteredPin() async {
    final isValid = await AuthService().verifyPin(_enteredPin);
    if (isValid && mounted) {
      _unlockSuccess();
    } else {
      if (mounted) {
        setState(() {
          _isError = true;
          _enteredPin = "";
        });
      }
    }
  }

  void _unlockSuccess() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ChatScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Lock Icon with glowing effect
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surfaceElevated,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3),
                    blurRadius: 25,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.lock_rounded,
                size: 42,
                color: AppTheme.primaryLight,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "حبيب عمري",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppTheme.textMain,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "بحبك يا مروة وربنا يجعلك حلالي ❤️",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFFF472B6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "أدخل الرمز السري أو بصمة الإصبع",
              style: TextStyle(
                fontSize: 13,
                color: _isError ? Colors.redAccent : AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 30),

            // 4 PIN Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final filled = index < _enteredPin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? AppTheme.primaryLight : AppTheme.surfaceElevated,
                    border: Border.all(
                      color: _isError
                          ? Colors.redAccent
                          : (filled ? AppTheme.primaryLight : AppTheme.textHint),
                      width: 2,
                    ),
                    boxShadow: filled
                        ? [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.6),
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                );
              }),
            ),

            const Spacer(),

            // Numeric Keyboard (Telegram Style)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  _buildKeyboardRow(["1", "2", "3"]),
                  const SizedBox(height: 18),
                  _buildKeyboardRow(["4", "5", "6"]),
                  const SizedBox(height: 18),
                  _buildKeyboardRow(["7", "8", "9"]),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Biometrics button
                      _buildIconButton(
                        icon: Icons.fingerprint_rounded,
                        onTap: _promptBiometrics,
                      ),
                      _buildNumberButton("0"),
                      // Backspace button
                      _buildIconButton(
                        icon: Icons.backspace_outlined,
                        onTap: _onDelete,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: digits.map((d) => _buildNumberButton(d)).toList(),
    );
  }

  Widget _buildNumberButton(String digit) {
    return InkWell(
      onTap: () => _onDigitPress(digit),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.surfaceElevated,
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Center(
          child: Text(
            digit,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMain,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.surfaceElevated.withOpacity(0.6),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 30,
            color: AppTheme.primaryLight,
          ),
        ),
      ),
    );
  }
}
