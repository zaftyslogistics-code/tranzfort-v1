import '../models/chat_model.dart';
import '../models/chat_message_model.dart';

abstract class ChatDataSource {
  Future<List<ChatModel>> getChats({String? userId});
  Stream<List<ChatModel>> watchChats({String? userId});
  Future<ChatModel?> getChatById(String chatId);
  Future<String> getOrCreateChatId({
    required String loadId,
    required String supplierId,
    required String truckerId,
  });
  Future<List<ChatMessageModel>> getMessages(
    String chatId, {
    int limit = 50,
    DateTime? before,
  });
  Stream<List<ChatMessageModel>> watchMessages(String chatId);
  Future<ChatMessageModel> sendMessage(
    String chatId,
    String senderId,
    String messageText,
  );
  Future<void> markAsRead(String chatId, String userId);
}
