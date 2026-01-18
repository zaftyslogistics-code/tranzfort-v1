import 'package:dartz/dartz.dart';
import '../entities/chat.dart';
import '../entities/chat_message.dart';
import '../../../../core/errors/failures.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<Chat>>> getChats({String? userId});
  Future<Either<Failure, Chat?>> getChatById(String chatId);
  Future<Either<Failure, List<ChatMessage>>> getMessages(String chatId);
  Stream<List<ChatMessage>> watchMessages(String chatId);
  Future<Either<Failure, ChatMessage>> sendMessage(
    String chatId,
    String senderId,
    String messageText,
  );
  Future<Either<Failure, void>> markAsRead(String chatId, String userId);
}
