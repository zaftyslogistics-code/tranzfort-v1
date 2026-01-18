import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class SendMessage {
  final ChatRepository repository;

  SendMessage(this.repository);

  Future<Either<Failure, ChatMessage>> call(
    String chatId,
    String senderId,
    String messageText,
  ) async {
    return await repository.sendMessage(chatId, senderId, messageText);
  }
}
