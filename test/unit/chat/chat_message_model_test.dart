import 'package:flutter_test/flutter_test.dart';
import 'package:transfort_app/features/chat/data/models/chat_message_model.dart';

void main() {
  group('ChatMessageModel', () {
    final testJson = {
      'id': 'msg-123',
      'chatId': 'chat-456',
      'senderId': 'user-789',
      'messageText': 'Hello, how are you?',
      'isRead': false,
      'createdAt': '2026-01-18T10:00:00.000Z',
    };

    test('fromJson creates ChatMessageModel from JSON', () {
      final messageModel = ChatMessageModel.fromJson(testJson);

      expect(messageModel.id, 'msg-123');
      expect(messageModel.chatId, 'chat-456');
      expect(messageModel.senderId, 'user-789');
      expect(messageModel.messageText, 'Hello, how are you?');
      expect(messageModel.isRead, false);
    });

    test('toJson converts ChatMessageModel to JSON', () {
      final messageModel = ChatMessageModel(
        id: 'msg-123',
        chatId: 'chat-456',
        senderId: 'user-789',
        messageText: 'Hello, how are you?',
        isRead: false,
        createdAt: DateTime.parse('2026-01-18T10:00:00.000Z'),
      );

      final json = messageModel.toJson();

      expect(json['id'], 'msg-123');
      expect(json['chatId'], 'chat-456');
      expect(json['senderId'], 'user-789');
      expect(json['messageText'], 'Hello, how are you?');
      expect(json['isRead'], false);
    });

    test('ChatMessageModel properties are accessible', () {
      final messageModel = ChatMessageModel(
        id: 'msg-123',
        chatId: 'chat-456',
        senderId: 'user-789',
        messageText: 'Test message content',
        isRead: true,
        createdAt: DateTime.parse('2026-01-18T10:00:00.000Z'),
      );

      expect(messageModel.id, 'msg-123');
      expect(messageModel.messageText, 'Test message content');
      expect(messageModel.isRead, true);
    });

    test('handles unread messages', () {
      final unreadMessage = ChatMessageModel(
        id: 'msg-999',
        chatId: 'chat-456',
        senderId: 'user-789',
        messageText: 'Unread message',
        isRead: false,
        createdAt: DateTime.now(),
      );

      expect(unreadMessage.isRead, false);
    });
  });
}
