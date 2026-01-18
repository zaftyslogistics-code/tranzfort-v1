import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chat.dart';
import '../repositories/chat_repository.dart';

class GetChatById {
  final ChatRepository repository;

  GetChatById(this.repository);

  Future<Either<Failure, Chat?>> call(String chatId) async {
    return await repository.getChatById(chatId);
  }
}
