import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'love_hub_screen.dart';

class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  String _userPhone = "";
  String _userName = "أحمد";
  String _partnerName = "مروة";
  Timer? _timer;

  // Love Dates
  final DateTime _loveStartDate = DateTime(2022, 2, 18); // 18 Feb 2022
  final DateTime _engagementDate = DateTime(2027, 7, 1);  // 1 July 2027
  final DateTime _ahmedBirthday = DateTime(1995, 7, 1);  // 1 July
  final DateTime _marwaBirthday = DateTime(1997, 4, 1);  // 1 April

  @override
  void initState() {
    super.initState();
    _loadUser();
    // Update every minute for live countdown
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadUser() async {
    final phone = await AuthService().getUserPhone() ?? "";
    final name = await AuthService().getUserName();
    final partner = await AuthService().getPartnerName();

    if (mounted) {
      setState(() {
        _userPhone = phone;
        _userName = name;
        _partnerName = partner;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Calculate days together
  Duration get _togetherDuration => DateTime.now().difference(_loveStartDate);

  // Calculate next birthday countdown
  Duration _getCountdownToNext(int month, int day) {
    final now = DateTime.now();
    DateTime target = DateTime(now.year, month, day);
    if (target.isBefore(now)) {
      target = DateTime(now.year + 1, month, day);
    }
    return target.difference(now);
  }

  @override
  Widget build(BuildContext context) {
    final isAhmed = _userPhone == "01021983866" || _userName.contains("أحمد");
    final partnerBirthdayCountdown = isAhmed 
        ? _getCountdownToNext(4, 1)   // Countdown to Marwa's birthday (April 1)
        : _getCountdownToNext(7, 1);  // Countdown to Ahmed's birthday (July 1)
    
    final engagementCountdown = _engagementDate.difference(DateTime.now());

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 1,
        title: const Text(
          "ذكريات أحمد ومروة 💍",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textMain),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Romantic Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A154B), Color(0xFF1D0E2E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.primaryLight.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text("👰🏻‍♀️ ❤️ 🤵🏻‍♂️", style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  const Text(
                    "عالم أحمد ومروة الخاص",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "\"بحبك يا مروة وربنا يجعلك حلالي ونور عيني\"",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Color(0xFFF472B6), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 20),

            // 1. LOVE DAYS COUNTER (عداد أيام حبنا)
            _buildDaysTogetherCard(),

            const SizedBox(height: 16),

            // 2. PARTNER BIRTHDAY COUNTDOWN (عداد عيد ميلاد الحبيب)
            _buildBirthdayCountdownCard(
              title: isAhmed ? "فاضل إيه على عيد ميلاد مروة 🎂" : "فاضل إيه على عيد ميلاد أحمد 🎂",
              subtitle: isAhmed ? "يوم 1 إبريل (أجمل هدية في عمري) ❤️" : "يوم 1 يوليو (سندي وحبيبي) 👑",
              duration: partnerBirthdayCountdown,
              accentColor: isAhmed ? const Color(0xFFEC4899) : const Color(0xFFA855F7),
            ),

            const SizedBox(height: 16),

            // 3. ENGAGEMENT COUNTDOWN (العد التنازلي للخطوبة)
            _buildEngagementCountdownCard(engagementCountdown),

            const SizedBox(height: 16),

            // 4. TIMELINE OF OUR LOVE (محطات حبنا)
            _buildTimelineSection(),

            const SizedBox(height: 16),

            // 5. Link to Love Hub (كبسولة الزمن والأسئلة والأحلام)
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoveHubScreen()),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primary.withOpacity(0.3), AppTheme.accentPink.withOpacity(0.3)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.accentPink.withOpacity(0.5)),
                ),
                child: const Row(
                  children: [
                    Text("🎁", style: TextStyle(fontSize: 26)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ركن العشاق السري 💍💖",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                          ),
                          SizedBox(height: 3),
                          Text(
                            "كبسولة الزمن، سؤال اليوم، قائمة أحلامنا، وألبومنا السري",
                            style: TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.accentPink, size: 16),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDaysTogetherCard() {
    final days = _togetherDuration.inDays;
    final years = (days / 365).floor();
    final remainingDays = days % 365;
    final months = (remainingDays / 30).floor();
    final finalDays = remainingDays % 30;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite_rounded, color: AppTheme.accentPink, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                "عداد أيام حبنا (معاً منذ 18/2/2022) ❤️",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textMain),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Big Days Number
          Center(
            child: Column(
              children: [
                Text(
                  "$days",
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Color(0xFFC084FC),
                  ),
                ),
                const Text(
                  "يوماً من الحب والسعادة ولسه الجاي أحلى",
                  style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Breakdown (Years, Months, Days)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMiniMetric("$years", "سنوات"),
              Container(width: 1, height: 30, color: Colors.white12),
              _buildMiniMetric("$months", "أشهر"),
              Container(width: 1, height: 30, color: Colors.white12),
              _buildMiniMetric("$finalDays", "أيام"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
      ],
    );
  }

  Widget _buildBirthdayCountdownCard({
    required String title,
    required String subtitle,
    required Duration duration,
    required Color accentColor,
  }) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.cake_rounded, color: accentColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCountdownBox("$days", "يوم", accentColor),
              const SizedBox(width: 12),
              _buildCountdownBox("$hours", "ساعة", accentColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementCountdownCard(Duration duration) {
    final days = duration.inDays;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1430), Color(0xFF2E193C)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Text("💍", style: TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "العد التنازلي ليوم خطوبتنا 💍",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 2),
                const Text(
                  "1 يوليو 2027 (حلالنا وربنا يجمعنا)",
                  style: TextStyle(fontSize: 11, color: Color(0xFFF59E0B)),
                ),
                const SizedBox(height: 6),
                Text(
                  "متبقي $days يوم بإذن الله ❤️",
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownBox(String val, String unit, Color color) {
    return Container(
      width: 78,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(val, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(unit, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
        ],
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline_rounded, color: AppTheme.primaryLight, size: 20),
              SizedBox(width: 8),
              Text(
                "محطات لا تُنسى في حبنا ✨",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTimelineItem("18 فبراير 2022", "بداية حكايتنا وأجمل يوم في العمر ❤️", "💘"),
          _buildTimelineItem("1 إبريل 1997", "يوم ميلاد حبيبة قلبي مروة 🌸", "🎂"),
          _buildTimelineItem("1 يوليو 1995", "يوم ميلاد حبيب عمري وسندي أحمد 👑", "🎂"),
          _buildTimelineItem("1 يوليو 2027", "خطوبتنا وحلالنا وعالمنا الدائم معاً 💍", "👰🏻‍♀️"),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String date, String desc, String icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryLight)),
                Text(desc, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
