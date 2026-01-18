import 'package:flutter_test/flutter_test.dart';
import 'package:transfort_app/features/chat/data/models/chat_model.dart';

void main() {
  group('ChatModel', () {
    final testJson = {
      'id': 'chat-123',
      'loadId': 'load-456',
      'truckerId': 'trucker-789',
      'supplierId': 'supplier-012',
      'lastMessage': 'Hello, is this load still available?',
      'lastMessageAt': '2026-01-18T10:00:00.000Z',
      'unreadCount': 2,
      'createdAt': '2026-01-18T09:00:00.000Z',
      'updatedAt': '2026-01-18T10:00:00.000Z',
    };

    test('fromJson creates ChatModel from JSON', () {
      final chatModel = ChatModel.fromJson(testJson);

      expect(chatModel.id, 'chat-123');
      expect(chatModel.loadId, 'load-456');
      expect(chatModel.truckerId, 'trucker-789');
      expect(chatModel.supplierId, 'supplier-012');
      expect(chatModel.lastMessage, 'Hello, is this load still available?');
      expect(chatModel.unreadCount, 2);
    });

    test('toJson converts ChatModel to JSON', () {
      final chatModel = ChatModel(
        id: 'chat-123',
        loadId: 'load-456',
        truckerId: 'trucker-789',
        supplierId: 'supplier-012',
        lastMessage: 'Hello, is this load still available?',
        lastMessageAt: DateTime.parse('2026-01-18T10:00:00.000Z'),
        unreadCount: 2,
        createdAt: DateTime.parse('2026-01-18T09:00:00.000Z'),
        updatedAt: DateTime.parse('2026-01-18T10:00:00.000Z'),
      );

      final json = chatModel.toJson();

      expect(json['id'], 'chat-123');
      expect(json['loadId'], 'load-456');
      expect(json['truckerId'], 'trucker-789');
      expect(json['supplierId'], 'supplier-012');
      expect(json['lastMessage'], 'Hello, is this load still available?');
      expect(json['unreadCount'], 2);
    });

    test('ChatModel properties are accessible', () {
      final chatModel = ChatModel(
        id: 'chat-123',
        loadId: 'load-456',
        truckerId: 'trucker-789',
        supplierId: 'supplier-012',
        lastMessage: 'Test message',
        lastMessageAt: DateTime.parse('2026-01-18T10:00:00.000Z'),
        unreadCount: 5,
        createdAt: DateTime.parse('2026-01-18T09:00:00.000Z'),
        updatedAt: DateTime.parse('2026-01-18T10:00:00.000Z'),
      );

      expect(chatModel.id, 'chat-123');
      expect(chatModel.unreadCount, 5);
      expect(chatModel.lastMessage, 'Test message');
    });
  });
}
