import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'scheduled_messages_screen.dart';
import 'stories_screen.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onWallpaperChanged;
  const SettingsScreen({super.key, required this.onWallpaperChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _wallpaperPath;
  String? _myAvatarPath;
  double _opacity = 0.35;
  String _selectedThemeId = "violet";
  String _serverUrl = "";

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final path = await AuthService().getChatWallpaper();
    final op = await AuthService().getWallpaperOpacity();
    final theme = prefs.getString("selected_app_theme") ?? "violet";
    final avatar = prefs.getString("user_custom_avatar");

    setState(() {
      _wallpaperPath = path;
      _opacity = op;
      _selectedThemeId = theme;
      _myAvatarPath = avatar;
      _serverUrl = AuthService().serverUrl;
    });
  }

  Future<void> _pickAvatar() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("user_custom_avatar", file.path);
      setState(() => _myAvatarPath = file.path);
      widget.onWallpaperChanged();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم تحديث صورتك الشخصية بنجاح ❤️")),
        );
      }
    }
  }

  Future<void> _pickWallpaper() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      await AuthService().setChatWallpaper(file.path);
      setState(() => _wallpaperPath = file.path);
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
    setState(() => _wallpaperPath = null);
    widget.onWallpaperChanged();
  }

  Future<void> _selectTheme(String themeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("selected_app_theme", themeId);
    AppTheme.setTheme(themeId);
    setState(() => _selectedThemeId = themeId);
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
            hintText: "الرمز الحالي: 141997",
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
              setState(() => _serverUrl = urlController.text.trim());
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
        title: const Text("الإعدادات والثيمات", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section 1: Profile Avatar
          _buildSectionHeader("صورتي الشخصية 👤"),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppTheme.primary.withOpacity(0.2),
                      backgroundImage: _myAvatarPath != null ? FileImage(File(_myAvatarPath!)) : null,
                      child: _myAvatarPath == null
                          ? const Text("🤵🏻‍♂️", style: TextStyle(fontSize: 30))
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickAvatar,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("تغيير الصورة الشخصية", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 2),
                      const Text("تظهر لحبيبك في أعلى الشات والبروفايل", style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      const SizedBox(height: 6),
                      TextButton(
                        onPressed: _pickAvatar,
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 24)),
                        child: Text("اختيار صورة من المعرض 📷", style: TextStyle(fontSize: 12, color: AppTheme.primaryLight)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Section 2: Telegram-like Themes
          _buildSectionHeader("ثيمات تليجرام وألوان التطبيق 🎨"),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "اختر ستايل الألوان المفضل لك ولمروة:",
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 105,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: AppTheme.presets.length,
                    itemBuilder: (context, idx) {
                      final p = AppTheme.presets[idx];
                      final isSelected = p.id == _selectedThemeId;
                      return GestureDetector(
                        onTap: () => _selectTheme(p.id),
                        child: Container(
                          width: 82,
                          margin: const EdgeInsets.only(left: 10),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: p.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.white12,
                              width: isSelected ? 2.5 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(colors: [p.bubbleStart, p.bubbleEnd]),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check, size: 20, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                p.name.split(" ")[0],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Section 3: Custom Chat Wallpaper
          _buildSectionHeader("خلفية المحادثة (صورنا سوا) 🖼️"),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "اختر صورتك أنت ومروة لتكون خلفية الشات:",
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickWallpaper,
                      icon: const Icon(Icons.image_rounded, size: 16),
                      label: const Text("اختيار صورة", style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                    ),
                    if (_wallpaperPath != null) ...[
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _removeWallpaper,
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent),
                        child: const Text("إزالة الخلفية", style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ],
                ),
                if (_wallpaperPath != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    "شفافية وتعتيم الخلفية: ${(_opacity * 100).toInt()}%",
                    style: TextStyle(fontSize: 11, color: AppTheme.primaryLight),
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

          // Section 4: Romantic Features Shortcuts
          _buildSectionHeader("أقسام ورومانسيات عالمنا 🌟"),
          _buildSettingsTile(
            icon: Icons.alarm_rounded,
            title: "الرسائل المجدولة والتلقائية ⏰",
            subtitle: "جدولة 'صباح الخير' وكلمات الحب في أوقات محددة",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScheduledMessagesScreen()),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.auto_awesome_rounded,
            title: "حالات عالمنا الخاص (Stories) 🌟",
            subtitle: "نشر حالات كلام وصور وفيديوهات خاصة بكم",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StoriesScreen()),
              );
            },
          ),

          const SizedBox(height: 20),

          // Section 5: Security & Compatibility
          _buildSectionHeader("الأمان والتوافق 🔒"),
          _buildSettingsTile(
            icon: Icons.pin_rounded,
            title: "تغيير الرمز السري",
            subtitle: "الرمز الحالي: 141997",
            onTap: _showChangePinDialog,
          ),
          _buildSettingsTile(
            icon: Icons.android_rounded,
            title: "توافق نظام الأندرويد",
            subtitle: "مفعل: يدعم جميع أجهزة الأندرويد القديمة والحديثة (Android 5.0+)",
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.cloud_outlined,
            title: "رابط السيرفر",
            subtitle: _serverUrl.isNotEmpty ? _serverUrl : "غير محدد",
            onTap: _showServerSettings,
          ),

          const SizedBox(height: 26),

          // Footer
          Center(
            child: Column(
              children: [
                const Text("عالمنا الخاص v2.5 💜", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                const SizedBox(height: 4),
                const Text("إهداء بكل الحب من أحمد إلى مروة ❤️", style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
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
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryLight),
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
        title: Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textHint),
        onTap: onTap,
      ),
    );
  }
}
