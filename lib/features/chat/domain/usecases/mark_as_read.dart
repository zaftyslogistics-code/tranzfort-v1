import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/chat_repository.dart';

class MarkAsRead {
  final ChatRepository repository;

  MarkAsRead(this.repository);

  Future<Either<Failure, void>> call(String chatId, String userId) async {
    return await repository.markAsRead(chatId, userId);
  }
}
