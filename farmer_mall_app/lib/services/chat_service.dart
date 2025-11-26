import 'package:farmer_mall_app/services/api_service.dart';
import 'package:farmer_mall_app/services/socket_service.dart';
import 'package:farmer_mall_app/models/message.dart';

class ChatService {
  static final SocketService _socketService = SocketService();

  // Connect to chat
  static Future<void> connect(int userId) async {
    await _socketService.connect();
    _socketService.socket?.emit('join', userId);
  }

  // Send message
  static void sendMessage({
    required int receiverId,
    required String message,
    int? productId,
  }) {
    _socketService.socket?.emit('send_message', {
      'receiver_id': receiverId,
      'message': message,
      'product_id': productId,
    });
  }

  // Listen for incoming messages
  static void onMessageReceived(Function(Message) callback) {
    _socketService.socket?.on('receive_message', (data) {
      if (data is Map) {
        callback(Message.fromMap(data));
      }
    });
  }

  // Listen for sent message confirmation
  static void onMessageSent(Function(Message) callback) {
    _socketService.socket?.on('message_sent', (data) {
      if (data is Map) {
        callback(Message.fromMap(data));
      }
    });
  }

  // Get chat history
  static Future<List<Message>> getChatHistory(
      int userId, int otherUserId) async {
    final res = await ApiService.get('/chat/history/$userId/$otherUserId');
    if (res['statusCode'] == 200 && res['body'] is List) {
      return (res['body'] as List).map((e) => Message.fromMap(e)).toList();
    }
    return [];
  }

  // Get all conversations
  static Future<List<Map<String, dynamic>>> getConversations(int userId) async {
    final res = await ApiService.get('/chat/conversations/$userId');
    if (res['statusCode'] == 200 && res['body'] is List) {
      return (res['body'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Remove listeners
  static void removeListeners() {
    _socketService.socket?.off('receive_message');
    _socketService.socket?.off('message_sent');
  }

  // Disconnect
  static void disconnect() {
    _socketService.disconnect();
  }
}
