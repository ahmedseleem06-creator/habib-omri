import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class StoryItem {
  final String id;
  final String authorName;
  final String authorRole; // husband or fiancee
  final String type; // text, image, video
  final String content; // text content or media url
  final int gradientIndex;
  final DateTime timestamp;

  StoryItem({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.type,
    required this.content,
    this.gradientIndex = 0,
    required this.timestamp,
  });
}

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<StoryItem> _stories = [
    StoryItem(
      id: "1",
      authorName: "مروة",
      authorRole: "fiancee",
      type: "text",
      content: "أنت أجمل حاجة حصلت في عمري كله يا أحمد.. ربنا يجمعنا على خير قريب 💍💜",
      gradientIndex: 0,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    StoryItem(
      id: "2",
      authorName: "أحمد",
      authorRole: "husband",
      type: "text",
      content: "بحبك يا مروة وربنا يجعلك حلالي ونور بيتي دائماً ❤️✨",
      gradientIndex: 1,
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
  ];

  static const List<List<Color>> _storyGradients = [
    [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCB045)],
    [Color(0xFF6B21A8), Color(0xFF9333EA), Color(0xFFEC4899)],
    [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
    [Color(0xFFD4145A), Color(0xFFFBB03B)],
  ];

  void _showAddStoryModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceElevated,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "إضافة حالة جديدة في عالمنا الخاص 🌟",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 18),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.text_fields_rounded, color: AppTheme.primaryLight),
                ),
                title: const Text("حالة كلامية (اكتب كلام حلو)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text("كلام رومانسي بخلفية ملونة", style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  _createTextStory();
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppTheme.accentPink.withOpacity(0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.photo_library_rounded, color: AppTheme.accentPink),
                ),
                title: const Text("حالة صورة 📷", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text("اختر صورة من المعرض لحالتك", style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final file = await _picker.pickImage(source: ImageSource.gallery);
                  if (file != null) {
                    _addMediaStory(file.path, isVideo: false);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createTextStory() {
    final textController = TextEditingController();
    int selectedGrad = 0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            height: 380,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: _storyGradients[selectedGrad]),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                    const Text("اكتب حالتك ❤️", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.color_lens_rounded, color: Colors.white),
                      onPressed: () {
                        setModalState(() {
                          selectedGrad = (selectedGrad + 1) % _storyGradients.length;
                        });
                      },
                    ),
                  ],
                ),
                const Spacer(),
                TextField(
                  controller: textController,
                  maxLines: 4,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "اكتب ما تشعر به الآن لمروة...",
                    hintStyle: TextStyle(color: Colors.white60),
                    border: InputBorder.none,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    final txt = textController.text.trim();
                    if (txt.isNotEmpty) {
                      setState(() {
                        _stories.insert(
                          0,
                          StoryItem(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            authorName: "أنا",
                            authorRole: "husband",
                            type: "text",
                            content: txt,
                            gradientIndex: selectedGrad,
                            timestamp: DateTime.now(),
                          ),
                        );
                      });
                      Navigator.pop(ctx);
                    }
                  },
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text("نشر الحالة 🌟"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addMediaStory(String path, {required bool isVideo}) {
    setState(() {
      _stories.insert(
        0,
        StoryItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          authorName: "أنا",
          authorRole: "husband",
          type: isVideo ? "video" : "image",
          content: path,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  void _openStoryViewer(StoryItem story) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                // Story content
                Center(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: _storyGradients[story.gradientIndex]),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Center(
                      child: Text(
                        story.content,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, height: 1.4),
                      ),
                    ),
                  ),
                ),

                // Top Bar
                Positioned(
                  top: 10,
                  left: 14,
                  right: 14,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white24,
                        child: Text(story.authorRole == "fiancee" ? "👰🏻‍♀️" : "🤵🏻‍♂️", style: const TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(width: 8),
                      Text(story.authorName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: const Text("حالات عالمنا الخاص 🌟", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStoryModal,
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.camera_alt_rounded, color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Add my status tile
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(18),
            ),
            child: ListTile(
              leading: Stack(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white24,
                    child: Text("❤️", style: TextStyle(fontSize: 20)),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.add, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
              title: const Text("إضافة حالة جديدة", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: const Text("شارك كلمتك أو صورتك لمروة", style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              onTap: _showAddStoryModal,
            ),
          ),

          const SizedBox(height: 20),
          const Text("الحالات الأخيرة ❤️", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryLight, fontSize: 13)),
          const SizedBox(height: 10),

          // Story items list
          ..._stories.map((story) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.accentPink]),
                  ),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: AppTheme.surface,
                    child: Text(story.authorRole == "fiancee" ? "👰🏻‍♀️" : "🤵🏻‍♂️", style: const TextStyle(fontSize: 18)),
                  ),
                ),
                title: Text(story.authorName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                subtitle: Text(story.content, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                trailing: const Icon(Icons.play_circle_fill_rounded, color: AppTheme.primaryLight, size: 28),
                onTap: () => _openStoryViewer(story),
              ),
            );
          }),
        ],
      ),
    );
  }
}
