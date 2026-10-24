import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../theme/app_theme.dart';
import 'lock_screen.dart';
import 'login_screen.dart';
import 'memories_screen.dart';
import 'scheduled_messages_screen.dart';
import 'settings_screen.dart';
import 'stories_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'love_hub_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  final ImagePicker _picker = ImagePicker();

  String _myPhone = "";
  String _partnerName = "مروة عمري";
  bool _isPartnerOnline = false;
  bool _isPartnerTyping = false;
  bool _isUploading = false;
  bool _showEmojiPicker = false;
  String? _wallpaperPath;
  String? _myAvatarPath;
  double _wallpaperOpacity = 0.35;
  String _myMood = "مشتاق لك وبفكر فيك 🥺❤️";
  String _partnerMood = "طايرة من الفرحة ومبسوطة 🥰✨";
  Timer? _typingTimer;
  StreamSubscription? _chatSubscription;

  // =========================================================
  // Comprehensive WhatsApp & Telegram Full Categorized Emojis (8 Categories)
  // =========================================================
  final List<String> _loveEmojis = [
    '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍', '🤎', '💔',
    '❤️‍🔥', '❤️‍🩹', '❣️', '💕', '💞', '💓', '💗', '💖', '💘', '💝',
    '💟', '💌', '🫶', '🫰', '💍', '💎', '💐', '🌹', '🥀', '🌺',
    '🌸', '🌼', '🌻', '🌷', '👰🏻‍♀️', '🤵🏻‍♂️', '👩‍❤️‍👨', '👩‍❤️‍💋‍👨', '💏', '💑',
    '🫂', '💋', '👑', '🕊️', '🥂', '🧸', '💒', '🎂', '🕯️', '🪄',
    '🫀', '🥰', '😍', '😘', '🥺', '😻', '😚', '😙', '✨', '⭐',
    '🌟', '💫', '🌙', '☀️', '🎀', '🎁', '💐', '🌷', '💌', '💍'
  ];

  final List<String> _smileysEmojis = [
    '😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣', '🥲', '🥹',
    '☺️', '😊', '😇', '🙂', '🙃', '😉', '😌', '😍', '🥰', '😘',
    '😗', '😙', '😚', '😋', '😛', '😝', '😜', '🤪', '🤨', '🧐',
    '🤓', '😎', '🥸', '🤩', '🥳', '😏', '😒', '😞', '😔', '😟',
    '😕', '🙁', '☹️', '😣', '😖', '😫', '😩', '🥺', '😢', '😭',
    '😮‍💨', '😤', '😠', '😡', '🤬', '🤯', '😳', '🥵', '🥶', '😱',
    '😨', '😰', '😥', '😓', '🫣', '🤗', '🫡', '🤔', '🫢', '🤫',
    '🤥', '😶', '😶‍🌫️', '😐', '😑', '😬', '🫨', '🫠', '🙄', '😯',
    '😦', '😧', '😮', '😲', '🥱', '😴', '🤤', '😪', '😵', '😵‍💫',
    '🤐', '🥴', '🤢', '🤮', '🤧', '😷', '🤒', '🤕', '🤑', '🤠',
    '😈', '👿', '👹', '👺', '🤡', '💩', '👻', '💀', '☠️', '👽'
  ];

  final List<String> _gesturesEmojis = [
    '👍', '👎', '👌', '🤌', '🤏', '✌️', '🤞', '🫰', '🤟', '🤘',
    '🤙', '👈', '👉', '👆', '👇', '☝️', '✋', '🤚', '🖐️', '🖖',
    '👋', '🤝', '👏', '🙌', '👐', '🤲', '🙏', '✍️', '💅', '🤳',
    '💪', '🦾', '🦿', '🦵', '🦶', '👂', '👃', '🧠', '👀', '👁️',
    '👅', '👄', '🫦', '🫂', '🧑‍🤝‍🧑', '👭', '👬', '👫', '💃', '🕺',
    '🏃‍♂️', '🏃‍♀️', '🚶‍♂️', '🚶‍♀️', '🧍‍♂️', '🧍‍♀️', '🧎‍♂️', '🧎‍♀️', '🙋‍♂️', '🙋‍♀️',
    '🤷‍♂️', '🤷‍♀️', '🤦‍♂️', '🤦‍♀️', '🙇‍♂️', '🙇‍♀️', '💁‍♂️', '💁‍♀️', '🙅‍♂️', '🙅‍♀️'
  ];

  final List<String> _natureEmojis = [
    '🌹', '💐', '🌷', '🌺', '🌸', '🌼', '🌻', '🥀', '🍀', '☘️',
    '🌿', '🌱', '🌾', '🪴', '🌴', '🌳', '🌲', '🍂', '🍁', '🍄',
    '🐱', '🐶', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯', '🦁', '🐮',
    '🐷', '🐸', '🐵', '🐔', '🐧', '🐦', '🐤', '🦆', '🦅', '🦉',
    '🦇', '🐺', '🐴', '🦄', '🐝', '🦋', '🐌', '🐞', '🐢', '🐍',
    '🐙', '🐬', '🐳', '🐟', '🐡', '🐠', '🦭', '🐆', '🦓', '🦒',
    '🐘', '🦔', '🕊️', '🐾', '🪴', '🍃', '☀️', '🌤️', '⛅', '🌈'
  ];

  final List<String> _foodEmojis = [
    '☕', '🫖', '🧃', '🥤', '🧋', '🥛', '🍼', '🍫', '🍬', '🍭',
    '🎂', '🍰', '🧁', '🍩', '🍪', '🍨', '🍧', '🍦', '🥧', '🍓',
    '🍒', '🍎', '🍏', '🍐', '🍊', '🍋', '🍌', '🍉', '🍇', '🫐',
    '🍈', '🍑', '🥭', '🍍', '🥥', '🥝', '🥞', '🧇', '🍕', '🍔',
    '🍟', '🌭', '🥪', '🌮', '🌯', '🥗', '🍝', '🍜', '🍲', '🍛',
    '🍣', '🍱', '🥟', '🍤', '🍿', '🧈', '🧀', '🍳', '🥐', '🥖'
  ];

  final List<String> _activitiesEmojis = [
    '🎉', '🎊', '🎈', '🎁', '🎀', '🪄', '🪅', '✨', '⭐', '🌟',
    '💫', '🔥', '💥', '🏆', '🥇', '🥈', '🥉', '🏅', '🎖️', '🎫',
    '🎟️', '🎪', '🎭', '🎨', '🎬', '🎤', '🎧', '🎼', '🎹', '🥁',
    '🎷', '🎺', '🎸', '🎻', '🎲', '🎯', '🎳', '🎮', '🕹️', '🎰',
    '🧩', '⚽', '🏀', '🏈', '⚾', '🎾', '🏐', '🏓', '🏸', '🥊',
    '🥋', '🛹', '🛼', '🚴‍♂️', '🚴‍♀️', '🏊‍♂️', '🏊‍♀️', '🏄‍♂️', '🏄‍♀️', '🧗‍♂️'
  ];

  final List<String> _travelEmojis = [
    '✈️', '🛫', '🛬', '🚀', '🛸', '🚁', '🚗', '🚕', '🚙', '🚌',
    '🏎️', '🚓', '🚑', '🚒', '🛵', '🏍️', '🚲', '🛴', '🚂', '🚆',
    '🚇', '🚊', '⛵', '🚤', '🛳️', '🚢', '🏖️', '🏝️', '🏜️', '🌋',
    '⛰️', '🏔️', '🏕️', '⛺', '🏠', '🏡', '🏘️', '🏰', '🗼', '🗽',
    '🏟️', '🎡', '🎢', '🎠', '⛲', '🕋', '🕌', '🌅', '🌄', '🌇',
    '🌆', '🌃', '🌌', '🌙', '🪐', '⛺', '🏖️', '🏨', '💒', '🏛️'
  ];

  final List<String> _symbolsEmojis = [
    '💌', '💎', '💍', '👑', '💡', '🕯️', '📱', '📲', '💻', '⌚',
    '⏰', '⏱️', '⏳', '⌛', '🔑', '🗝️', '🔒', '🔓', '🔏', '🔐',
    '❤️', '💖', '⚡', '☀️', '🌤️', '⛅', '🌧️', '⛈️', '❄️', '☃️',
    '🌈', '☂️', '☔', '🧿', '🪬', '🔮', '📿', '🔔', '🔕', '📢',
    '📣', '💬', '💭', '🗯️', '💯', '✅', '✔️', '☑️', '❌', '❎',
    '❓', '❗', '‼️', '⁉️', '➕', '➖', '✖️', '➗', '💲', '💱'
  ];
  int _selectedEmojiCategory = 0;

  @override
  void initState() {
    super.initState();
    _initChat();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final path = await AuthService().getChatWallpaper();
    final op = await AuthService().getWallpaperOpacity();
    final themeId = prefs.getString("selected_app_theme") ?? "violet";
    final avatar = prefs.getString("user_custom_avatar");
    AppTheme.setTheme(themeId);

    if (mounted) {
      setState(() {
        _wallpaperPath = path;
        _wallpaperOpacity = op;
        _myAvatarPath = avatar;
      });
    }
  }

  Future<void> _initChat() async {
    final phone = await AuthService().getUserPhone();
    if (phone == null) {
      _logout();
      return;
    }

    final isAhmed = phone == "01021983866";

    setState(() {
      _myPhone = phone;
      _partnerName = isAhmed ? "مروة عمري 💍" : "أحمد حبيب قلبي 👑";
    });

    // 1. Fetch historical messages
    final history = await ChatService().fetchHistory(phone);
    if (mounted) {
      setState(() {
        _messages.addAll(history);
      });
      _scrollToBottom();
    }

    // 2. Connect WebSocket
    ChatService().connect(phone);

    // 3. Listen to incoming real-time events
    _chatSubscription = ChatService().messageStream.listen((event) {
      if (!mounted) return;

      final type = event["event"];

      if (type == "new_message") {
        setState(() {
          _messages.add(event);
        });
        _scrollToBottom();

        if (event["receiver_phone"] == _myPhone && event["id"] != null) {
          ChatService().sendReadReceipt([event["id"]]);
        }
      } else if (type == "heartbeat" || type == "heartbeat_received") {
        _onReceiveHeartbeat(event["sender_name"] ?? "حبيبك");
      } else if (type == "partner_mood_updated" || type == "mood_update") {
        if (mounted) {
          setState(() {
            _partnerMood = event["mood"] ?? "";
          });
        }
      } else if (type == "typing") {
        setState(() {
          _isPartnerTyping = event["is_typing"] ?? false;
        });
      } else if (type == "presence") {
        setState(() {
          _isPartnerOnline = event["is_online"] ?? false;
        });
      } else if (type == "messages_read") {
        final List<dynamic> ids = event["message_ids"] ?? [];
        setState(() {
          for (var msg in _messages) {
            if (ids.contains(msg["id"])) {
              msg["status"] = "read";
            }
          }
        });
      } else if (type == "message_liked") {
        final msgId = event["message_id"];
        final isLiked = event["is_liked"] ?? 0;
        setState(() {
          for (var msg in _messages) {
            if (msg["id"] == msgId) {
              msg["is_liked"] = isLiked;
            }
          }
        });
      }
    });
  }

  void _sendMessage({String msgType = "text", String mediaUrl = "", String textOverride = ""}) {
    final text = textOverride.isNotEmpty ? textOverride : _textController.text.trim();
    if (text.isEmpty && mediaUrl.isEmpty) return;

    ChatService().sendMessage(text, msgType: msgType, mediaUrl: mediaUrl);
    if (textOverride.isEmpty) {
      _textController.clear();
      _onTextChanged("");
    }
    _scrollToBottom();
  }

  // Multi-Image Picker
  Future<void> _pickAndSendMultipleImages() async {
    try {
      final List<XFile> files = await _picker.pickMultiImage(imageQuality: 90);
      if (files.isEmpty) return;

      setState(() => _isUploading = true);

      for (var file in files) {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse("${AuthService().serverUrl}/api/upload"),
        );
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          _sendMessage(msgType: "image", mediaUrl: data["url"]);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("تعذر رفع الصور: $e")),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _pickAndSendVideo() async {
    try {
      final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
      if (file == null) return;

      setState(() => _isUploading = true);

      final request = http.MultipartRequest(
        'POST',
        Uri.parse("${AuthService().serverUrl}/api/upload"),
      );
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _sendMessage(msgType: "video", mediaUrl: data["url"], textOverride: "🎥 مقطع فيديو");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("تعذر رفع الفيديو: $e")),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _sendVoiceNote() {
    _sendMessage(msgType: "voice", textOverride: "🎙️ رسالة صوتية دافئة (0:24)");
  }

  void _onTextChanged(String text) {
    if (text.isNotEmpty) {
      ChatService().sendTyping(true);
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 2), () {
        ChatService().sendTyping(false);
      });
    } else {
      ChatService().sendTyping(false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleLike(Map<String, dynamic> msg) {
    final msgId = msg["id"];
    if (msgId == null) return;
    final current = msg["is_liked"] ?? 0;
    final next = current == 1 ? 0 : 1;
    ChatService().toggleLike(msgId, next);
  }

  void _lockApp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LockScreen()),
    );
  }

  void _logout() async {
    await AuthService().logout();
    ChatService().disconnect();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  // Full-Screen Image Viewer with Pinch-to-Zoom
  void _openFullScreenImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black45,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text("عالمنا الخاص ❤️", style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.8,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image, size: 60, color: Colors.white54),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  // -----------------------------------------------------------
  // Heartbeat Sync & Mood Tracker
  // -----------------------------------------------------------
  void _sendHeartbeatPulse() {
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 160), () => HapticFeedback.heavyImpact());
    Future.delayed(const Duration(milliseconds: 320), () => HapticFeedback.heavyImpact());

    ChatService().sendMessage("💓 نبضة حب: أنا بفكر فيكي دلوقتي ونبضات قلبي بتناديكي ❤️", type: "heartbeat");

    _showHeartbeatOverlay(isSender: true, name: _partnerName);
  }

  void _onReceiveHeartbeat(String senderName) {
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 160), () => HapticFeedback.heavyImpact());
    Future.delayed(const Duration(milliseconds: 320), () => HapticFeedback.heavyImpact());

    _showHeartbeatOverlay(isSender: false, name: senderName);
  }

  void _showHeartbeatOverlay({required bool isSender, required String name}) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (ctx) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [AppTheme.accentPink, Colors.transparent],
                  stops: [0.4, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentPink.withOpacity(0.6),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.favorite_rounded, size: 75, color: Colors.white),
              ),
            )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(begin: const Offset(0.85, 0.85), end: const Offset(1.2, 1.2), duration: 600.ms),
            const SizedBox(height: 24),
            Text(
              isSender ? "تم إرسال نبضات قلبك لحبيبتك ❤️" : "$name بيبعتلك نبضات قلبه دلوقتي! 💓",
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isSender ? "موبايلها بيهتز بنبضات قلبك في نفس اللحظة ✨" : "بحبك يا مروة وربنا يجعلك حلالي ونور حياتي 💍",
              style: TextStyle(color: AppTheme.primaryLight, fontSize: 12, decoration: TextDecoration.none),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (!isSender) {
                  _sendHeartbeatPulse();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentPink),
              child: Text(isSender ? "حبيبي دايماً في بالي ❤️" : "رد بنبضة حب فورية 💓"),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoodPicker() {
    final moods = [
      "مشتاق لك وبفكر فيك 🥺❤️",
      "طاير من الفرحة ومبسوط 🥰✨",
      "تعبان ومحتاج حنية ودعوة 🤒🫂",
      "مضغوط في الشغل ومحتاجك جنبي 💼🤍",
      "روقان ومستني أسمع صوتك ☕🌸",
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceElevated,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("كيف تشعر الآن؟ (مؤشر المزاج العاطفي) 🥰", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
              const SizedBox(height: 6),
              const Text("سيظهر مزاجك لحبيبك في أعلى الشات فوراً ليشاركك مشاعرك:", style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              const SizedBox(height: 14),
              ...moods.map((m) => ListTile(
                title: Text(m, style: const TextStyle(fontSize: 13, color: Colors.white)),
                trailing: _myMood == m ? const Icon(Icons.check_circle_rounded, color: AppTheme.accentPink) : null,
                onTap: () async {
                  setState(() => _myMood = m);
                  Navigator.pop(ctx);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString("user_current_mood", m);
                  ChatService().sendMessage(m, type: "mood_update");
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _chatSubscription?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 1,
        titleSpacing: 0,
        title: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryLight, width: 2),
                    gradient: const LinearGradient(
                      colors: [AppTheme.accentPink, AppTheme.accentPink],
                    ),
                  ),
                  child: Center(
                    child: Text(_myPhone == "01021983866" ? "👰🏻‍♀️" : "🤵🏻‍♂️", style: const TextStyle(fontSize: 20)),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _isPartnerOnline ? const Color(0xFF10B981) : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.surface, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            // Partner Name & Status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _partnerName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textMain,
                    ),
                  ),
                  Text(
                    _isPartnerTyping
                        ? "يكتب الآن... ✍️"
                        : (_isPartnerOnline ? "متصلة الآن 🟢" : "غير متصل"),
                    style: TextStyle(
                      fontSize: 11,
                      color: _isPartnerTyping
                          ? AppTheme.primaryLight
                          : (_isPartnerOnline ? const Color(0xFF10B981) : AppTheme.textMuted),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Live Heartbeat Sync Button (نبضة قلب لحظية)
          IconButton(
            icon: const Icon(Icons.favorite_rounded, color: AppTheme.accentPink),
            tooltip: "نبضة قلب لحظية (Heartbeat)",
            onPressed: _sendHeartbeatPulse,
          ),
          // Romantic Love Hub (ركن العشاق • كبسولة الزمن والأسئلة والأحلام)
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFBBF24)),
            tooltip: "ركن العشاق (كبسولة الزمن والأسئلة والأحلام)",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoveHubScreen()),
              );
            },
          ),
          // Memories Vault Button (ذكرياتنا والعداد)
          IconButton(
            icon: Icon(Icons.calendar_month_rounded, color: AppTheme.primaryLight),
            tooltip: "قسم ذكرياتنا والعداد",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MemoriesScreen()),
              );
            },
          ),
          // Scheduled Messages Button (الرسائل المجدولة)
          IconButton(
            icon: Icon(Icons.alarm_rounded, color: AppTheme.primaryLight),
            tooltip: "الرسائل المجدولة التلقائية",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScheduledMessagesScreen()),
              );
            },
          ),
          // Settings Button (الثيمات والخلفية)
          IconButton(
            icon: Icon(Icons.settings_outlined, color: AppTheme.primaryLight),
            tooltip: "الإعدادات والثيمات",
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(onWallpaperChanged: _loadSettings),
                ),
              );
              _loadSettings();
            },
          ),
          IconButton(
            icon: const Icon(Icons.lock_outline_rounded, color: AppTheme.textMuted),
            tooltip: "قفل التطبيق",
            onPressed: _lockApp,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Custom Wallpaper Background if selected
          if (_wallpaperPath != null)
            Positioned.fill(
              child: Opacity(
                opacity: _wallpaperOpacity,
                child: Image.file(
                  File(_wallpaperPath!),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
            ),

          Column(
            children: [
              // 0. Mood Status Tracker Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                color: AppTheme.surface,
                child: Row(
                  children: [
                    InkWell(
                      onTap: _showMoodPicker,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.primaryLight.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("حالتي: ", style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                            Text(_myMood, style: TextStyle(fontSize: 10, color: AppTheme.primaryLight, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 4),
                            Icon(Icons.edit, size: 10, color: AppTheme.primaryLight),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.accentPink.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.accentPink.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_myPhone == "01021983866" ? "مروة: " : "أحمد: ", style: const TextStyle(fontSize: 10, color: AppTheme.accentPink, fontWeight: FontWeight.bold)),
                          Text(_partnerMood, style: const TextStyle(fontSize: 10, color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Stories Row (حالات عالمنا الخاص)
              Container(
                height: 78,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surface.withOpacity(0.92),
                  border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06))),
                ),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildStoryAvatar(
                      name: "حالتي ➕",
                      avatar: _myPhone == "01021983866" ? "🤵🏻‍♂️" : "👰🏻‍♀️",
                      isAdd: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const StoriesScreen()),
                        );
                      },
                    ),
                    const SizedBox(width: 14),
                    _buildStoryAvatar(
                      name: _partnerName.split(" ")[0],
                      avatar: _myPhone == "01021983866" ? "👰🏻‍♀️" : "🤵🏻‍♂️",
                      hasStory: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const StoriesScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Sticky Romantic Dedication Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF26123D), Color(0xFF3B1238), Color(0xFF26123D)],
                  ),
                  border: Border(bottom: BorderSide(color: AppTheme.accentPink.withOpacity(0.3))),
                ),
                child: const Center(
                  child: Text(
                    "💍 \" بحبك يا مروة وربنا يجعلك حلالي \" ❤️",
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFFF472B6)),
                  ),
                ),
              ),

              if (_isUploading)
                LinearProgressIndicator(
                  color: AppTheme.accentPink,
                  backgroundColor: AppTheme.surface,
                ),

              // Messages List
              Expanded(
                child: _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.mark_chat_unread_outlined, size: 50, color: AppTheme.primaryLight.withOpacity(0.4)),
                            const SizedBox(height: 10),
                            const Text("أهلاً بكم في عالم أحمد ومروة ❤️", style: TextStyle(fontSize: 15, color: AppTheme.textMuted)),
                            const SizedBox(height: 4),
                            const Text("ابدأوا محادثتكم بأحلى كلام وذكريات...", style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isMe = msg["sender_phone"] == _myPhone;
                          return _buildMessageBubble(msg, isMe);
                        },
                      ),
              ),

              // Bottom Input Bar
              _buildInputBar(),

              // Comprehensive Emoji Keyboard Tray
              if (_showEmojiPicker) _buildEmojiTray(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoryAvatar({
    required String name,
    required String avatar,
    bool isAdd = false,
    bool hasStory = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: hasStory
                      ? LinearGradient(colors: [AppTheme.primary, AppTheme.accentPink])
                      : null,
                  border: isAdd ? Border.all(color: Colors.white24, width: 1.5) : null,
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.surfaceElevated,
                  child: Text(avatar, style: const TextStyle(fontSize: 18)),
                ),
              ),
              if (isAdd)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.add, size: 12, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(name, style: const TextStyle(fontSize: 10, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe) {
    final timestamp = msg["timestamp"] != null
        ? DateTime.fromMillisecondsSinceEpoch((msg["timestamp"] * 1000).toInt())
        : DateTime.now();
    final timeStr = intl.DateFormat('h:mm a').format(timestamp);
    final isLiked = msg["is_liked"] == 1;
    final status = msg["status"] ?? "sent";
    final msgType = msg["msg_type"] ?? "text";
    final mediaUrl = msg["media_url"] ?? "";

    return GestureDetector(
      onDoubleTap: () => _toggleLike(msg),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
                    decoration: BoxDecoration(
                      gradient: isMe
                          ? LinearGradient(
                              colors: [AppTheme.myBubbleStart, AppTheme.myBubbleEnd],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isMe ? null : AppTheme.partnerBubble.withOpacity(0.95),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
                        bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Photo Message with Full Aspect Ratio & Zoom Tap
                        if (msgType == "image" && mediaUrl.isNotEmpty) ...[
                          GestureDetector(
                            onTap: () => _openFullScreenImage("${AuthService().serverUrl}$mediaUrl"),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                "${AuthService().serverUrl}$mediaUrl",
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 120,
                                  color: Colors.black26,
                                  child: const Center(child: Icon(Icons.broken_image, color: Colors.white54)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],

                        // Video Message
                        if (msgType == "video" && mediaUrl.isNotEmpty) ...[
                          Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.white24,
                                child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],

                        // Voice Message
                        if (msgType == "voice") ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.white24,
                                child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.white54,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text("0:24", style: TextStyle(fontSize: 11, color: Colors.white70)),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],

                        // Text Content
                        if ((msg["content"] ?? "").isNotEmpty && msgType != "voice")
                          Text(
                            msg["content"],
                            style: const TextStyle(fontSize: 15, color: Colors.white, height: 1.35),
                          ),

                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(timeStr, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.65))),
                            if (isMe) ...[
                              const SizedBox(width: 4),
                              Icon(
                                status == "read"
                                    ? Icons.done_all_rounded
                                    : (status == "delivered" ? Icons.done_all_rounded : Icons.done_rounded),
                                size: 14,
                                color: status == "read" ? AppTheme.primaryLight : Colors.white.withOpacity(0.65),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Romantic Heart Reaction
                  if (isLiked)
                    Positioned(
                      bottom: -8,
                      right: isMe ? null : -6,
                      left: isMe ? -6 : null,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceElevated,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: AppTheme.accentPink.withOpacity(0.4), blurRadius: 8),
                          ],
                        ),
                        child: const Icon(Icons.favorite, size: 14, color: AppTheme.accentPink),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: const Border(top: BorderSide(color: Color(0xFF1E1730), width: 1)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    // Emoji Picker Toggle
                    IconButton(
                      icon: Icon(
                        _showEmojiPicker ? Icons.keyboard_rounded : Icons.sentiment_satisfied_alt_rounded,
                        color: AppTheme.primaryLight,
                        size: 22,
                      ),
                      onPressed: () {
                        setState(() => _showEmojiPicker = !_showEmojiPicker);
                        if (_showEmojiPicker) FocusScope.of(context).unfocus();
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        onChanged: _onTextChanged,
                        onTap: () {
                          if (_showEmojiPicker) setState(() => _showEmojiPicker = false);
                        },
                        style: const TextStyle(color: AppTheme.textMain, fontSize: 14.5),
                        decoration: InputDecoration(
                          hintText: "رسالة إلى $_partnerName...",
                          hintStyle: const TextStyle(color: AppTheme.textHint, fontSize: 13.5),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    // Multi-Image & Video Attachment Button
                    IconButton(
                      icon: Icon(Icons.attach_file_rounded, color: AppTheme.primaryLight, size: 22),
                      onPressed: _showAttachmentSheet,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Voice Note or Send Button
            _textController.text.trim().isEmpty
                ? InkWell(
                    onTap: _sendVoiceNote,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.surfaceElevated,
                      ),
                      child: Center(
                        child: Icon(Icons.mic_rounded, color: AppTheme.primaryLight, size: 22),
                      ),
                    ),
                  )
                : InkWell(
                    onTap: () => _sendMessage(),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppTheme.primary, AppTheme.accentPink],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.send_rounded, color: Colors.white, size: 19),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceElevated,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAttachmentOption(
                icon: Icons.photo_library_rounded,
                label: "إرسال صور (متعددة) 📷",
                color: AppTheme.primaryLight,
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndSendMultipleImages();
                },
              ),
              _buildAttachmentOption(
                icon: Icons.videocam_rounded,
                label: "إرسال فيديو 🎥",
                color: AppTheme.accentPink,
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndSendVideo();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiTray() {
    List<String> activeList = _loveEmojis;
    if (_selectedEmojiCategory == 1) activeList = _smileysEmojis;
    if (_selectedEmojiCategory == 2) activeList = _gesturesEmojis;
    if (_selectedEmojiCategory == 3) activeList = _natureEmojis;
    if (_selectedEmojiCategory == 4) activeList = _foodEmojis;
    if (_selectedEmojiCategory == 5) activeList = _activitiesEmojis;
    if (_selectedEmojiCategory == 6) activeList = _travelEmojis;
    if (_selectedEmojiCategory == 7) activeList = _symbolsEmojis;

    return Container(
      height: 270,
      color: AppTheme.surface,
      child: Column(
        children: [
          // Emoji Category Switcher Tabs + Backspace Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: AppTheme.surfaceElevated,
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildEmojiCategoryTab(0, "حب ورومانسية ❤️💍"),
                        const SizedBox(width: 5),
                        _buildEmojiCategoryTab(1, "ابتسامات 😊"),
                        const SizedBox(width: 5),
                        _buildEmojiCategoryTab(2, "حركات وأيدي 👍"),
                        const SizedBox(width: 5),
                        _buildEmojiCategoryTab(3, "طبيعة وورود 🌹"),
                        const SizedBox(width: 5),
                        _buildEmojiCategoryTab(4, "أكل ومشروبات ☕"),
                        const SizedBox(width: 5),
                        _buildEmojiCategoryTab(5, "احتفال وألعاب 🎉"),
                        const SizedBox(width: 5),
                        _buildEmojiCategoryTab(6, "سفر وأماكن ✈️"),
                        const SizedBox(width: 5),
                        _buildEmojiCategoryTab(7, "رموز وأشياء 💡"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // WhatsApp-style Backspace Button
                InkWell(
                  onTap: () {
                    final text = _textController.text;
                    if (text.isNotEmpty) {
                      final chars = text.characters;
                      if (chars.isNotEmpty) {
                        _textController.text = chars.skipLast(1).toString();
                        _textController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _textController.text.length),
                        );
                        _onTextChanged(_textController.text);
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.primaryLight.withOpacity(0.2)),
                    ),
                    child: Icon(Icons.backspace_outlined, size: 18, color: AppTheme.primaryLight),
                  ),
                ),
              ],
            ),
          ),
          // Emoji Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: activeList.length,
              itemBuilder: (context, idx) {
                final em = activeList[idx];
                return InkWell(
                  onTap: () {
                    final curr = _textController.text;
                    _textController.text = curr + em;
                    _textController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _textController.text.length),
                    );
                    _onTextChanged(_textController.text);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Center(
                    child: Text(em, style: const TextStyle(fontSize: 24)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildEmojiCategoryTab(int index, String title) {
    final isSelected = _selectedEmojiCategory == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedEmojiCategory = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }
}
