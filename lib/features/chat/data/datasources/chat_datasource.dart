import '../models/chat_model.dart';
import '../models/chat_message_model.dart';

abstract class ChatDataSource {
  Future<List<ChatModel>> getChats({String? userId});
  Stream<List<ChatModel>> watchChats({String? userId});
  Future<ChatModel?> getChatById(String chatId);
  Future<List<ChatMessageModel>> getMessages(String chatId);
  Stream<List<ChatMessageModel>> watchMessages(String chatId);
  Future<ChatMessageModel> sendMessage(
    String chatId,
    String senderId,
    String messageText,
  );
  Future<void> markAsRead(String chatId, String userId);
}
