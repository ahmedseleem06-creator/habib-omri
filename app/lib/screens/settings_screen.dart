import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onWallpaperChanged;
  const SettingsScreen({super.key, required this.onWallpaperChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _wallpaperPath;
  double _opacity = 0.35;
  String _serverUrl = "";

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final path = await AuthService().getChatWallpaper();
    final op = await AuthService().getWallpaperOpacity();
    setState(() {
      _wallpaperPath = path;
      _opacity = op;
      _serverUrl = AuthService().serverUrl;
    });
  }

  Future<void> _pickWallpaper() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      await AuthService().setChatWallpaper(file.path);
      setState(() {
        _wallpaperPath = file.path;
      });
      widget.onWallpaperChanged();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم تعيين الصورة كخلفية للشات بنجاح ❤️")),
        );
      }
    }
  }

  Future<void> _removeWallpaper() async {
    await AuthService().setChatWallpaper(null);
    setState(() {
      _wallpaperPath = null;
    });
    widget.onWallpaperChanged();
  }

  void _showChangePinDialog() {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        title: const Text("تغيير الرمز السري", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "اكتب الرمز السري الجديد (مثلاً 141997)",
            hintStyle: TextStyle(color: AppTheme.textHint),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () async {
              final newPin = pinController.text.trim();
              if (newPin.isNotEmpty) {
                await AuthService().setAppPin(newPin);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("تم تحديث الرمز السري بنجاح")),
                );
              }
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  void _showServerSettings() {
    final urlController = TextEditingController(text: AuthService().serverUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        title: const Text("رابط السيرفر", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: urlController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "https://your-server.onrender.com",
            hintStyle: TextStyle(color: AppTheme.textHint),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () async {
              await AuthService().updateServerUrl(urlController.text.trim());
              Navigator.pop(ctx);
              setState(() {
                _serverUrl = urlController.text.trim();
              });
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
        backgroundColor: AppTheme.surface,
        title: const Text("الإعدادات والثيمات", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section 1: Chat Wallpaper
          _buildSectionHeader("خلفية المحادثة (صورنا سوا) 🖼️"),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "اختر صورتك أنت ومروة لتكون خلفية الشات الرومانسي:",
                  style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickWallpaper,
                      icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
                      label: const Text("اختيار صورة"),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                    ),
                    if (_wallpaperPath != null) ...[
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: _removeWallpaper,
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent),
                        child: const Text("إزالة الخلفية"),
                      ),
                    ],
                  ],
                ),
                if (_wallpaperPath != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    "شفافية وتعتيم الخلفية: ${(_opacity * 100).toInt()}%",
                    style: const TextStyle(fontSize: 12, color: AppTheme.primaryLight),
                  ),
                  Slider(
                    value: _opacity,
                    min: 0.1,
                    max: 0.9,
                    activeColor: AppTheme.primaryLight,
                    onChanged: (val) {
                      setState(() => _opacity = val);
                      AuthService().setWallpaperOpacity(val);
                      widget.onWallpaperChanged();
                    },
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Section 2: Security
          _buildSectionHeader("الأمان والخصوصية 🔒"),
          _buildSettingsTile(
            icon: Icons.pin_rounded,
            title: "تغيير الرمز السري",
            subtitle: "الرمز الحالي الافتراضي: 141997",
            onTap: _showChangePinDialog,
          ),

          const SizedBox(height: 20),

          // Section 3: Server
          _buildSectionHeader("الخادم والاتصال 🌐"),
          _buildSettingsTile(
            icon: Icons.cloud_outlined,
            title: "رابط السيرفر",
            subtitle: _serverUrl.isNotEmpty ? _serverUrl : "غير محدد",
            onTap: _showServerSettings,
          ),

          const SizedBox(height: 30),

          // About App
          Center(
            child: Column(
              children: [
                const Text("عالمنا الخاص v2.0 💜", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                const SizedBox(height: 4),
                const Text("صُنع بكل حب لأحمد ومروة ❤️", style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryLight),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryLight),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textHint),
        onTap: onTap,
      ),
    );
  }
}
