import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String messageText;
  final bool isRead;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.messageText,
    required this.isRead,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, chatId, senderId, messageText, isRead, createdAt];
}
