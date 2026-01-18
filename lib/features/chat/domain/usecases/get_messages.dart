import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class GetMessages {
  final ChatRepository repository;

  GetMessages(this.repository);

  Future<Either<Failure, List<ChatMessage>>> call(String chatId) async {
    return await repository.getMessages(chatId);
  }
}
