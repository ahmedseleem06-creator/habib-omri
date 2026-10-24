import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class LoveHubScreen extends StatefulWidget {
  final int initialTabIndex;
  const LoveHubScreen({super.key, this.initialTabIndex = 0});

  @override
  State<LoveHubScreen> createState() => _LoveHubScreenState();
}

class _LoveHubScreenState extends State<LoveHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();
  String _userPhone = "";
  bool _isAhmed = true;

  // -------------------------------------------------------------
  // 1. Time Capsule Data
  // -------------------------------------------------------------
  final List<Map<String, dynamic>> _capsules = [
    {
      "id": "1",
      "title": "رسالة سرية ليوم خطوبتنا المباركة 💍",
      "author": "أحمد",
      "targetDate": "2027-07-01",
      "message": "يا مروة قلبي.. اليوم ده هو بداية حياتنا وحلالنا، وعد مني أصونك وأسعدك لآخر يوم في عمري بحبك أوي ❤️",
      "isLocked": true,
    },
    {
      "id": "2",
      "title": "مفاجأة عيد ميلاد مروة 🎂",
      "author": "أحمد",
      "targetDate": "2027-04-01",
      "message": "كل سنة وأنتي أجمل وأغلى حاجة دخلت حياتي، عقبال 100 سنة في حضني وبيتنا سوا يا قمر 🌹✨",
      "isLocked": true,
    },
    {
      "id": "3",
      "title": "وعد ذكرى بداية حبنا 💖",
      "author": "مروة",
      "targetDate": "2023-02-18",
      "message": "من أول يوم قلبي دق فيه ليك، وأنا عارفة إنك نصيبي وحبيبي وعوض ربنا ليا.. بحبك يا أحمد 💜",
      "isLocked": false, // Date passed
    },
  ];

  // -------------------------------------------------------------
  // 2. Daily Couple Question Data
  // -------------------------------------------------------------
  final TextEditingController _quizAnswerController = TextEditingController();
  final String _todayQuestion = "إيه أكتر موقف خلاك تتأكد إن ربنا كتبنا لبعض؟ 💍";
  String? _myQuizAnswer;
  String? _partnerQuizAnswer;
  bool _isQuizRevealed = false;

  // -------------------------------------------------------------
  // 3. Bucket List Data
  // -------------------------------------------------------------
  final List<Map<String, dynamic>> _bucketList = [
    {
      "id": "1",
      "text": "عمرة وزيارة بيت الله الحرام معاً 🕋",
      "isDone": false,
      "dateAchieved": null,
    },
    {
      "id": "2",
      "text": "فرش وتجهيز شقة الزوجية باختيارنا سوا 🏡",
      "isDone": false,
      "dateAchieved": null,
    },
    {
      "id": "3",
      "text": "مشاهدة أول شروق شمس على البحر بعد الفرح 🌅",
      "isDone": false,
      "dateAchieved": null,
    },
    {
      "id": "4",
      "text": "طبخ أول أكلة سوا في مطبخ بيتنا 🍲",
      "isDone": false,
      "dateAchieved": null,
    },
    {
      "id": "5",
      "text": "جلسة تصوير (فوتوسيشن) مجنونة ورومانسية 📸",
      "isDone": true,
      "dateAchieved": "18/02/2024",
    },
  ];

  // -------------------------------------------------------------
  // 4. Secret Photo Album Data
  // -------------------------------------------------------------
  final List<Map<String, dynamic>> _secretAlbum = [
    {
      "id": "1",
      "category": "الخطوبة والشبكة 💍",
      "caption": "أول يوم لبسنا فيه الدبل وربطنا قلوبنا للأبد ❤️",
      "date": "01/07/2027",
      "imageUrl": "https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8?w=500&auto=format&fit=crop&q=80",
    },
    {
      "id": "2",
      "category": "خروجاتنا المميزة 🌹",
      "caption": "وردة لوردة قلبي في أحلى خروجة سوا ✨",
      "date": "18/02/2023",
      "imageUrl": "https://images.unsplash.com/photo-1522383225653-ed111181a951?w=500&auto=format&fit=crop&q=80",
    },
    {
      "id": "3",
      "category": "صور عفوية 🥰",
      "caption": "ضحكتك دي هي كل أسبابي للسعادة 💜",
      "date": "15/05/2024",
      "imageUrl": "https://images.unsplash.com/photo-1518199266791-5375a83190b7?w=500&auto=format&fit=crop&q=80",
    },
  ];

  // -------------------------------------------------------------
  // 5. Voice Vault Data
  // -------------------------------------------------------------
  final List<Map<String, dynamic>> _voiceVault = [
    {
      "id": "1",
      "title": "أول مرة تقوليلي بحبك بصوتك 💖",
      "author": "مروة",
      "duration": "0:45",
      "date": "18/02/2022",
      "isPlaying": false,
    },
    {
      "id": "2",
      "title": "دعوة من القلب ليلة خطوبتنا 💍",
      "author": "أحمد",
      "duration": "1:20",
      "date": "01/07/2024",
      "isPlaying": false,
    },
    {
      "id": "3",
      "title": "رسالة صوتية في عيد ميلادي 🎂",
      "author": "مروة",
      "duration": "0:58",
      "date": "01/07/2024",
      "isPlaying": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: widget.initialTabIndex);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final phone = await AuthService().getUserPhone() ?? "";
    setState(() {
      _userPhone = phone;
      _isAhmed = phone == "01021983866";
    });

    final prefs = await SharedPreferences.getInstance();
    final savedAnswer = prefs.getString("daily_quiz_my_answer");
    if (savedAnswer != null) {
      setState(() {
        _myQuizAnswer = savedAnswer;
        _partnerQuizAnswer = "الموقف لما وقفت معايا ومسبتنيش لحظة، وحسيت إنك أماني وسندي في الدنيا دي 💍❤️";
        _isQuizRevealed = true;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _quizAnswerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 1,
        title: const Text(
          "ركن العشاق • عالمنا الخاص 💍💖",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textMain),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppTheme.accentPink,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: AppTheme.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: const [
            Tab(icon: Icon(Icons.lock_clock_rounded, size: 20), text: "كبسولة الزمن ⏳"),
            Tab(icon: Icon(Icons.help_outline_rounded, size: 20), text: "سؤال اليوم ❓"),
            Tab(icon: Icon(Icons.checklist_rounded, size: 20), text: "أحلامنا سوا 📝"),
            Tab(icon: Icon(Icons.photo_library_rounded, size: 20), text: "ألبومنا السري 📸"),
            Tab(icon: Icon(Icons.graphic_eq_rounded, size: 20), text: "خزنة الفويس 🎙️"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTimeCapsuleTab(),
          _buildDailyQuizTab(),
          _buildBucketListTab(),
          _buildSecretAlbumTab(),
          _buildVoiceVaultTab(),
        ],
      ),
    );
  }

  // =============================================================
  // TAB 1: Time Capsule ⏳
  // =============================================================
  Widget _buildTimeCapsuleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary.withOpacity(0.2), AppTheme.accentPink.withOpacity(0.15)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryLight.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Text("⏳", style: TextStyle(fontSize: 28)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "اكتب رسالة سرية لحبيبك تتقفل بقفل ذكي وما تفتحش إلا في تاريخ معين (مثل يوم الخطوبة أو عيد الميلاد)!",
                    style: TextStyle(fontSize: 12, color: AppTheme.textMain, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ..._capsules.map((capsule) => _buildCapsuleCard(capsule)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _showAddCapsuleDialog,
            icon: const Icon(Icons.lock_rounded, size: 18),
            label: const Text("قفل رسالة جديدة في كبسولة الزمن ✨", style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapsuleCard(Map<String, dynamic> capsule) {
    final target = DateTime.parse(capsule["targetDate"]);
    final isLocked = target.isAfter(DateTime.now());
    final daysRemaining = target.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLocked ? Colors.amber.withOpacity(0.3) : AppTheme.primaryLight.withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isLocked ? Icons.lock_outline_rounded : Icons.lock_open_rounded,
                color: isLocked ? Colors.amber : Colors.greenAccent,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  capsule["title"],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textMain),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isLocked ? Colors.amber.withOpacity(0.15) : Colors.greenAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isLocked ? "مقفولة 🔒" : "جاهزة للفتح 💌",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isLocked ? Colors.amber : Colors.greenAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isLocked
                ? "تفتح تلقائياً في: ${capsule["targetDate"]} (فاضل $daysRemaining يوماً)"
                : "تاريخ الفتح: ${capsule["targetDate"]} (تم فك القفل بنجاح)",
            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              if (isLocked) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("هذه الرسالة مقفولة حتى ${capsule["targetDate"]}! لا يمكن استباق المفاجأة 😉🔒"),
                    backgroundColor: Colors.amber.shade900,
                  ),
                );
              } else {
                _openCapsuleMessage(capsule);
              }
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isLocked ? Colors.black26 : AppTheme.primary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isLocked ? Colors.white10 : AppTheme.primaryLight),
              ),
              alignment: Alignment.center,
              child: Text(
                isLocked ? "الرسالة مشفرة ومقفولة للأمان 🔐" : "اضغط هنا لقراءة الرسالة السرية ❤️",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isLocked ? AppTheme.textMuted : AppTheme.primaryLight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openCapsuleMessage(Map<String, dynamic> capsule) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.favorite_rounded, color: AppTheme.accentPink),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                capsule["title"],
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryLight.withOpacity(0.3)),
              ),
              child: Text(
                capsule["message"],
                style: const TextStyle(fontSize: 13, color: AppTheme.textMain, height: 1.5),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "المرسل: ${capsule["author"]} ❤️",
              style: const TextStyle(fontSize: 11, color: AppTheme.primaryLight, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("إغلاق", style: TextStyle(color: AppTheme.accentPink)),
          ),
        ],
      ),
    );
  }

  void _showAddCapsuleDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    DateTime selectedDate = DateTime(2027, 7, 1);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDState) => AlertDialog(
          backgroundColor: AppTheme.surfaceElevated,
          title: const Text("قفل رسالة في كبسولة الزمن ⏳", style: TextStyle(color: Colors.white, fontSize: 15)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: "عنوان الرسالة (مثلاً: ليوم الخطوبة 💍)",
                    labelStyle: TextStyle(color: AppTheme.textMuted),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: messageController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: "نص الرسالة السرية لحبيبك...",
                    labelStyle: TextStyle(color: AppTheme.textMuted),
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("تاريخ الفتح التلقائي:", style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  subtitle: Text(
                    "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}",
                    style: const TextStyle(color: AppTheme.primaryLight, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_month_rounded, color: AppTheme.primaryLight),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        setDState(() => selectedDate = picked);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("إلغاء", style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty && messageController.text.trim().isNotEmpty) {
                  setState(() {
                    _capsules.add({
                      "id": DateTime.now().millisecondsSinceEpoch.toString(),
                      "title": titleController.text.trim(),
                      "author": _isAhmed ? "أحمد" : "مروة",
                      "targetDate": "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}",
                      "message": messageController.text.trim(),
                      "isLocked": true,
                    });
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("تم قفل الرسالة في كبسولة الزمن بنجاح! 🔒❤️")),
                  );
                }
              },
              child: const Text("قفل الرسالة 🔒"),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // TAB 2: Daily Couple Question ❓
  // =============================================================
  Widget _buildDailyQuizTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Question Header Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.accentPink],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.quiz_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "سؤال حب اليوم ❓✨",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _todayQuestion,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "قاعدة اللعبة: إجابة كل طرف تظل مخفية ومقفولة ولا تظهر إلا بعد إجابة الطرفين معاً!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 10.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // User Input if not answered
          if (_myQuizAnswer == null) ...[
            const Text(
              "اكتب إجابتك الصادقة لحبيبك:",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMain),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _quizAnswerController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: "اكتب ما يشعر به قلبك هنا...",
                hintStyle: const TextStyle(color: AppTheme.textHint, fontSize: 12),
                filled: true,
                fillColor: AppTheme.surfaceElevated,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final ans = _quizAnswerController.text.trim();
                if (ans.isNotEmpty) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString("daily_quiz_my_answer", ans);
                  setState(() {
                    _myQuizAnswer = ans;
                    _partnerQuizAnswer = "الموقف لما وقفت معايا ومسبتنيش لحظة، وحسيت إنك أماني وسندي في الدنيا دي 💍❤️";
                    _isQuizRevealed = true;
                  });
                  HapticFeedback.mediumImpact();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              child: const Text("إرسال إجابتي وقفلها 🔒", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ] else ...[
            // Status Badges
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _isAhmed ? "أحمد: أجاب ✅" : "مروة: أجابت ✅",
                      style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _isAhmed ? "مروة: أجابت ✅" : "أحمد: أجاب ✅",
                      style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Revealed Answers Cards
            const Text(
              "إجاباتكم الرومانسية اليوم ❤️✨:",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMain),
            ),
            const SizedBox(height: 10),
            _buildQuizAnswerCard("إجابتك أنت (${_isAhmed ? "أحمد" : "مروة"})", _myQuizAnswer!, true),
            const SizedBox(height: 10),
            _buildQuizAnswerCard("إجابة حبيبتك (${_isAhmed ? "مروة" : "أحمد"})", _partnerQuizAnswer!, false),
          ],
        ],
      ),
    );
  }

  Widget _buildQuizAnswerCard(String author, String answer, bool isMine) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isMine ? AppTheme.primaryLight.withOpacity(0.4) : AppTheme.accentPink.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(author, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isMine ? AppTheme.primaryLight : AppTheme.accentPink)),
          const SizedBox(height: 6),
          Text(answer, style: const TextStyle(color: AppTheme.textMain, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }

  // =============================================================
  // TAB 3: Our Bucket List 📝
  // =============================================================
  Widget _buildBucketListTab() {
    final completedCount = _bucketList.where((b) => b["isDone"] == true).length;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress summary
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Text("📝", style: TextStyle(fontSize: 26)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("أحلامنا وأمنياتنا المشتركة 💍", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text("حققنا $completedCount من أصل ${_bucketList.length} أمنية حتى الآن", style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ..._bucketList.map((item) => _buildBucketItem(item)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _showAddBucketDialog,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text("إضافة حلم جديد لقائمتنا 🌟", style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildBucketItem(Map<String, dynamic> item) {
    final isDone = item["isDone"] == true;
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          item["isDone"] = !isDone;
          if (item["isDone"]) {
            item["dateAchieved"] = "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
          } else {
            item["dateAchieved"] = null;
          }
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDone ? Colors.greenAccent.withOpacity(0.4) : Colors.white10),
        ),
        child: Row(
          children: [
            Icon(
              isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: isDone ? Colors.greenAccent : AppTheme.textMuted,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["text"],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                      color: isDone ? Colors.white : AppTheme.textMain,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (item["dateAchieved"] != null)
                    Text(
                      "تم بحمد الله في: ${item["dateAchieved"]} ❤️",
                      style: const TextStyle(fontSize: 10, color: Colors.greenAccent, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBucketDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        title: const Text("أمنية جديدة لقائمتنا 💍", style: TextStyle(color: Colors.white, fontSize: 14)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "مثال: رحلة لشرم الشيخ سوا...",
            hintStyle: TextStyle(color: AppTheme.textHint, fontSize: 12),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء", style: TextStyle(color: AppTheme.textMuted))),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _bucketList.add({
                    "id": DateTime.now().millisecondsSinceEpoch.toString(),
                    "text": controller.text.trim(),
                    "isDone": false,
                    "dateAchieved": null,
                  });
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text("إضافة"),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // TAB 4: Secret Photo Album 📸
  // =============================================================
  Widget _buildSecretAlbumTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("ألبوم ذكرياتنا السري 📸✨", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
              ElevatedButton.icon(
                onPressed: _pickPhotoForAlbum,
                icon: const Icon(Icons.add_a_photo_rounded, size: 16),
                label: const Text("إضافة صورة", style: TextStyle(fontSize: 11)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ..._secretAlbum.map((photo) => _buildAlbumCard(photo)),
        ],
      ),
    );
  }

  Widget _buildAlbumCard(Map<String, dynamic> photo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryLight.withOpacity(0.2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _openFullPhoto(photo["imageUrl"]),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                photo["imageUrl"],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.black26, child: const Icon(Icons.image, size: 40)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        photo["category"],
                        style: const TextStyle(fontSize: 10, color: AppTheme.primaryLight, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(photo["date"], style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  photo["caption"],
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMain, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openFullPhoto(String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: Image.network(url, fit: BoxFit.contain),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPhotoForAlbum() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تمت إضافة الصورة للألبوم السري بنجاح ❤️")),
      );
    }
  }

  // =============================================================
  // TAB 5: Voice Vault 🎙️
  // =============================================================
  Widget _buildVoiceVaultTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.accentPink.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Text("🎙️", style: TextStyle(fontSize: 26)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "خزنة التسجيلات الصوتية الغالية.. احتفظوا بأجمل الفويس نوتس والمكالمات لسماعها في أي وقت حتى بدون إنترنت ❤️",
                    style: TextStyle(fontSize: 12, color: AppTheme.textMain, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ..._voiceVault.map((voice) => _buildVoiceCard(voice)),
        ],
      ),
    );
  }

  Widget _buildVoiceCard(Map<String, dynamic> voice) {
    final isPlaying = voice["isPlaying"] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isPlaying ? AppTheme.accentPink : Colors.white10),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                voice["isPlaying"] = !isPlaying;
              });
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPlaying ? AppTheme.accentPink : AppTheme.primary,
              ),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  voice["title"],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text("بصوت: ${voice["author"]}", style: const TextStyle(fontSize: 10.5, color: AppTheme.primaryLight)),
                    const Text(" • ", style: TextStyle(color: AppTheme.textMuted)),
                    Text(voice["date"], style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted)),
                    const Spacer(),
                    Text(voice["duration"], style: const TextStyle(fontSize: 10.5, color: Colors.white70)),
                  ],
                ),
                const SizedBox(height: 6),
                // Waveform indicator bar
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: isPlaying ? 0.65 : 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.accentPink,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
