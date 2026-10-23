import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'auth_service.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _messagesController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messagesController.stream;

  bool isConnected = false;
  Timer? _reconnectTimer;
  String? _currentUserPhone;

  void connect(String userPhone) {
    _currentUserPhone = userPhone;
    _reconnectTimer?.cancel();

    try {
      final base = AuthService().serverUrl;
      // Convert http:// to ws:// and https:// to wss://
      final wsUrl = base.replaceFirst("http://", "ws://").replaceFirst("https://", "wss://");
      final uri = Uri.parse("$wsUrl/ws/$userPhone");

      _channel = WebSocketChannel.connect(uri);
      isConnected = true;

      _channel!.stream.listen(
        (data) {
          try {
            final decoded = jsonDecode(data);
            _messagesController.add(decoded);
          } catch (e) {
            // handle decode error
          }
        },
        onDone: () {
          isConnected = false;
          _scheduleReconnect();
        },
        onError: (err) {
          isConnected = false;
          _scheduleReconnect();
        },
      );
    } catch (e) {
      isConnected = false;
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 4), () {
      if (_currentUserPhone != null && !isConnected) {
        connect(_currentUserPhone!);
      }
    });
  }

  void sendMessage(String content, {String msgType = "text", String mediaUrl = ""}) {
    if (_channel != null && isConnected) {
      _channel!.sink.add(jsonEncode({
        "type": "message",
        "content": content,
        "msg_type": msgType,
        "media_url": mediaUrl,
      }));
    }
  }

  void sendTyping(bool isTyping) {
    if (_channel != null && isConnected) {
      _channel!.sink.add(jsonEncode({
        "type": "typing",
        "is_typing": isTyping,
      }));
    }
  }

  void sendReadReceipt(List<int> messageIds) {
    if (_channel != null && isConnected && messageIds.isNotEmpty) {
      _channel!.sink.add(jsonEncode({
        "type": "read_receipt",
        "message_ids": messageIds,
      }));
    }
  }

  void toggleLike(int messageId, int isLiked) {
    if (_channel != null && isConnected) {
      _channel!.sink.add(jsonEncode({
        "type": "toggle_like",
        "message_id": messageId,
        "is_liked": isLiked,
      }));
    }
  }

  Future<List<Map<String, dynamic>>> fetchHistory(String phone) async {
    try {
      final response = await http.get(
        Uri.parse("${AuthService().serverUrl}/api/messages?phone=$phone"),
      );
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      // offline fallback
    }
    return [];
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    isConnected = false;
  }
}
