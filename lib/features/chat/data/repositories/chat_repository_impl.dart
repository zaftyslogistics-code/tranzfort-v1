import 'package:dartz/dartz.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/mock_chat_datasource.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatDataSource dataSource;

  ChatRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<Chat>>> getChats({String? userId}) async {
    try {
      final models = await dataSource.getChats(userId: userId);
      return Right(models.map(_modelToEntity).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Chat?>> getChatById(String chatId) async {
    try {
      final model = await dataSource.getChatById(chatId);
      if (model == null) return const Right(null);
      return Right(_modelToEntity(model));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(String chatId) async {
    try {
      final models = await dataSource.getMessages(chatId);
      return Right(models.map(_messageModelToEntity).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String chatId) {
    return dataSource.watchMessages(chatId).map(
          (models) => models.map(_messageModelToEntity).toList(),
        );
  }

  @override
  Future<Either<Failure, ChatMessage>> sendMessage(
    String chatId,
    String senderId,
    String messageText,
  ) async {
    try {
      final model = await dataSource.sendMessage(chatId, senderId, messageText);
      return Right(_messageModelToEntity(model));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String chatId, String userId) async {
    try {
      await dataSource.markAsRead(chatId, userId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Chat _modelToEntity(model) {
    return Chat(
      id: model.id,
      loadId: model.loadId,
      truckerId: model.truckerId,
      supplierId: model.supplierId,
      status: model.status,
      lastMessage: model.lastMessage,
      lastMessageAt: model.lastMessageAt,
      unreadCount: model.unreadCount,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  ChatMessage _messageModelToEntity(model) {
    return ChatMessage(
      id: model.id,
      chatId: model.chatId,
      senderId: model.senderId,
      messageText: model.messageText,
      isRead: model.isRead,
      createdAt: model.createdAt,
    );
  }
}
