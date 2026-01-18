import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chat.dart';
import '../repositories/chat_repository.dart';

class GetChats {
  final ChatRepository repository;

  GetChats(this.repository);

  Future<Either<Failure, List<Chat>>> call({String? userId}) async {
    return await repository.getChats(userId: userId);
  }
}
