import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/chat_service.dart';
import '../theme/app_theme.dart';

class ScheduledMessage {
  final String id;
  final String text;
  final String timeString; // e.g., "10:00 AM"
  final int hour;
  final int minute;
  final bool isDaily;
  bool isEnabled;

  ScheduledMessage({
    required this.id,
    required this.text,
    required this.timeString,
    required this.hour,
    required this.minute,
    this.isDaily = true,
    this.isEnabled = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'timeString': timeString,
    'hour': hour,
    'minute': minute,
    'isDaily': isDaily,
    'isEnabled': isEnabled,
  };

  factory ScheduledMessage.fromJson(Map<String, dynamic> json) => ScheduledMessage(
    id: json['id'],
    text: json['text'],
    timeString: json['timeString'],
    hour: json['hour'],
    minute: json['minute'],
    isDaily: json['isDaily'] ?? true,
    isEnabled: json['isEnabled'] ?? true,
  );
}

class ScheduledMessagesScreen extends StatefulWidget {
  const ScheduledMessagesScreen({super.key});

  @override
  State<ScheduledMessagesScreen> createState() => _ScheduledMessagesScreenState();
}

class _ScheduledMessagesScreenState extends State<ScheduledMessagesScreen> {
  final List<ScheduledMessage> _schedules = [];
  static const String _prefKey = "couples_scheduled_messages";

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_prefKey);
    if (data != null) {
      final List<dynamic> list = jsonDecode(data);
      setState(() {
        _schedules.clear();
        _schedules.addAll(list.map((e) => ScheduledMessage.fromJson(e)));
      });
    } else {
      // Seed default romantic schedules
      setState(() {
        _schedules.addAll([
          ScheduledMessage(
            id: "1",
            text: "صباح الخير يا حبيب عمري ونور عيني ☀️❤️",
            timeString: "10:00 ص",
            hour: 10,
            minute: 0,
            isDaily: true,
          ),
          ScheduledMessage(
            id: "2",
            text: "تصبحي على جنة يا أجمل مروة في الكون 🌙✨💍",
            timeString: "11:30 م",
            hour: 23,
            minute: 30,
            isDaily: true,
          ),
        ]);
      });
      _saveSchedules();
    }
  }

  Future<void> _saveSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _schedules.map((e) => e.toJson()).toList();
    await prefs.setString(_prefKey, jsonEncode(list));
  }

  void _showAddDialog() {
    final textController = TextEditingController();
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surfaceElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "جدولة رسالة رومانسية تلقائية ⏰💌",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("نص الرسالة:", style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              const SizedBox(height: 6),
              TextField(
                controller: textController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "مثلاً: صباح الخير يا عمري بحبك...",
                  hintStyle: const TextStyle(color: AppTheme.textHint, fontSize: 13),
                  filled: true,
                  fillColor: AppTheme.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 14),
              const Text("وقت الإرسال:", style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              const SizedBox(height: 6),
              InkWell(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (picked != null) {
                    setDialogState(() => selectedTime = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${selectedTime.format(context)} (يومياً)",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryLight),
                      ),
                      Icon(Icons.access_time_rounded, color: AppTheme.primaryLight, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
            ElevatedButton(
              onPressed: () {
                final txt = textController.text.trim();
                if (txt.isNotEmpty) {
                  setState(() {
                    _schedules.add(ScheduledMessage(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      text: txt,
                      timeString: selectedTime.format(context),
                      hour: selectedTime.hour,
                      minute: selectedTime.minute,
                      isDaily: true,
                    ));
                  });
                  _saveSchedules();
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("تمت إضافة الرسالة المجدولة بنجاح ❤️")),
                  );
                }
              },
              child: const Text("حفظ وتفعيل"),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteSchedule(int index) {
    setState(() {
      _schedules.removeAt(index);
    });
    _saveSchedules();
  }

  void _sendNow(ScheduledMessage item) {
    ChatService().sendMessage(item.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم إرسال الرسالة إلى الشات الآن بنجاح! 💌")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: const Text("الرسائل المجدولة والتلقائية ⏰", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add_alarm_rounded, color: Colors.white),
        label: const Text("رسالة جديدة", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: _schedules.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.schedule_rounded, size: 60, color: AppTheme.primaryLight.withOpacity(0.4)),
                  const SizedBox(height: 12),
                  const Text("لا توجد رسائل مجدولة حالياً", style: TextStyle(color: AppTheme.textMuted)),
                  const SizedBox(height: 6),
                  const Text("اضغط على زر 'رسالة جديدة' لجدولة صباح الخير أو كلام حلو", style: TextStyle(color: AppTheme.textHint, fontSize: 12)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _schedules.length,
              itemBuilder: (context, index) {
                final item = _schedules[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: item.isEnabled ? AppTheme.primary.withOpacity(0.3) : Colors.white10,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.alarm_rounded, size: 14, color: AppTheme.primaryLight),
                                    const SizedBox(width: 4),
                                    Text(
                                      item.timeString,
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryLight),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text("• تتكرر يومياً", style: TextStyle(fontSize: 11, color: AppTheme.textHint)),
                            ],
                          ),
                          Switch(
                            value: item.isEnabled,
                            activeColor: AppTheme.primaryLight,
                            onChanged: (val) {
                              setState(() => item.isEnabled = val);
                              _saveSchedules();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.text,
                        style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.35),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _sendNow(item),
                            icon: Icon(Icons.send_rounded, size: 14, color: AppTheme.primaryLight),
                            label: Text("إرسال الآن", style: TextStyle(fontSize: 12, color: AppTheme.primaryLight)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                            onPressed: () => _deleteSchedule(index),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
