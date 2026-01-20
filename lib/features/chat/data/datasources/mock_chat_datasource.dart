import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'dart:async';
import '../../../../core/utils/logger.dart';
import '../models/chat_model.dart';
import '../models/chat_message_model.dart';

abstract class ChatDataSource {
  Future<List<ChatModel>> getChats({String? userId});
  Stream<List<ChatModel>> watchChats({String? userId});
  Future<ChatModel?> getChatById(String chatId);
  Future<List<ChatMessageModel>> getMessages(String chatId);
  Stream<List<ChatMessageModel>> watchMessages(String chatId);
  Future<ChatMessageModel> sendMessage(
    String chatId,
    String senderId,
    String messageText,
  );
  Future<void> markAsRead(String chatId, String userId);
}

class MockChatDataSource implements ChatDataSource {
  final SharedPreferences prefs;
  final Uuid uuid = const Uuid();
  final Map<String, StreamController<List<ChatMessageModel>>> _controllers = {};

  MockChatDataSource(this.prefs);

  @override
  Future<List<ChatModel>> getChats({String? userId}) async {
    Logger.info('💬 MOCK: Getting chats');
    var chats = await _getAllChats();

    if (chats.isEmpty) {
      await _seedSampleChats();
      chats = await _getAllChats();
    }

    if (userId != null) {
      chats = chats
          .where((chat) => chat.truckerId == userId || chat.supplierId == userId)
          .toList();
    }

    chats.sort((a, b) {
      final aTime = a.lastMessageAt ?? a.createdAt;
      final bTime = b.lastMessageAt ?? b.createdAt;
      return bTime.compareTo(aTime);
    });

    Logger.info('✅ MOCK: Found ${chats.length} chats');
    return chats;
  }

  @override
  Stream<List<ChatModel>> watchChats({String? userId}) {
    // Basic mock implementation that just emits the current list once
    // In a real mock, we'd use a StreamController to emit updates
    return Stream.fromFuture(getChats(userId: userId));
  }

  @override
  Future<ChatModel?> getChatById(String chatId) async {
    final chats = await _getAllChats();
    try {
      return chats.firstWhere((chat) => chat.id == chatId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String chatId) async {
    final messagesJson = prefs.getString(_messagesKey(chatId));
    if (messagesJson == null) return [];

    final List<dynamic> decoded = jsonDecode(messagesJson);
    return decoded.map((json) => ChatMessageModel.fromJson(json)).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Stream<List<ChatMessageModel>> watchMessages(String chatId) {
    final controller = _controllers.putIfAbsent(
      chatId,
      () => StreamController<List<ChatMessageModel>>.broadcast(),
    );

    getMessages(chatId).then((messages) {
      if (!controller.isClosed) {
        controller.add(messages);
      }
    });

    return controller.stream;
  }

  @override
  Future<ChatMessageModel> sendMessage(
    String chatId,
    String senderId,
    String messageText,
  ) async {
    final newMessage = ChatMessageModel(
      id: uuid.v4(),
      chatId: chatId,
      senderId: senderId,
      messageText: messageText,
      isRead: false,
      createdAt: DateTime.now(),
    );

    final messages = await getMessages(chatId);
    final updatedMessages = [...messages, newMessage];
    await _saveMessages(chatId, updatedMessages);

    await _updateChatPreview(chatId, newMessage);
    _notify(chatId, updatedMessages);

    Logger.info('✅ MOCK: Message sent: ${newMessage.id}');
    return newMessage;
  }

  @override
  Future<void> markAsRead(String chatId, String userId) async {
    final messages = await getMessages(chatId);
    final updatedMessages = messages
        .map((m) => m.senderId == userId ? m : m.copyWith(isRead: true))
        .toList();
    await _saveMessages(chatId, updatedMessages);

    final chat = await getChatById(chatId);
    if (chat != null) {
      final updatedChat = chat.copyWith(unreadCount: 0);
      await _saveChat(updatedChat);
    }

    _notify(chatId, updatedMessages);
  }

  Future<List<ChatModel>> _getAllChats() async {
    final chatsJson = prefs.getString(_chatsKey());
    if (chatsJson == null) return [];

    final List<dynamic> decoded = jsonDecode(chatsJson);
    return decoded.map((json) => ChatModel.fromJson(json)).toList();
  }

  Future<void> _saveChat(ChatModel chat) async {
    final chats = await _getAllChats();
    final index = chats.indexWhere((c) => c.id == chat.id);
    if (index >= 0) {
      chats[index] = chat;
    } else {
      chats.add(chat);
    }
    await _saveChats(chats);
  }

  Future<void> _saveChats(List<ChatModel> chats) async {
    final chatsJson = jsonEncode(chats.map((c) => c.toJson()).toList());
    await prefs.setString(_chatsKey(), chatsJson);
  }

  Future<void> _saveMessages(String chatId, List<ChatMessageModel> messages) async {
    final messagesJson = jsonEncode(messages.map((m) => m.toJson()).toList());
    await prefs.setString(_messagesKey(chatId), messagesJson);
  }

  Future<void> _updateChatPreview(String chatId, ChatMessageModel message) async {
    final chat = await getChatById(chatId);
    if (chat == null) return;

    final updatedChat = chat.copyWith(
      lastMessage: message.messageText,
      lastMessageAt: message.createdAt,
      unreadCount: chat.unreadCount + 1,
      updatedAt: DateTime.now(),
    );
    await _saveChat(updatedChat);
  }

  void _notify(String chatId, List<ChatMessageModel> messages) {
    final controller = _controllers[chatId];
    if (controller != null && !controller.isClosed) {
      controller.add(messages);
    }
  }

  String _chatsKey() => 'chat_list';
  String _messagesKey(String chatId) => 'chat_messages_$chatId';

  Future<void> _seedSampleChats() async {
    Logger.info('🌱 MOCK: Seeding sample chats');
    final now = DateTime.now();

    final chat1 = ChatModel(
      id: uuid.v4(),
      loadId: 'load-1',
      truckerId: 'sample-trucker',
      supplierId: 'sample-supplier',
      status: 'active',
      lastMessage: 'Can you share loading time?',
      lastMessageAt: now.subtract(const Duration(minutes: 15)),
      unreadCount: 1,
      createdAt: now.subtract(const Duration(days: 1)),
      updatedAt: now.subtract(const Duration(minutes: 15)),
    );

    final chat2 = ChatModel(
      id: uuid.v4(),
      loadId: 'load-2',
      truckerId: 'sample-trucker',
      supplierId: 'sample-supplier',
      status: 'active',
      lastMessage: 'Sure, let me confirm.',
      lastMessageAt: now.subtract(const Duration(hours: 3)),
      unreadCount: 0,
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now.subtract(const Duration(hours: 3)),
    );

    await _saveChats([chat1, chat2]);

    await _saveMessages(
      chat1.id,
      [
        ChatMessageModel(
          id: uuid.v4(),
          chatId: chat1.id,
          senderId: chat1.truckerId,
          messageText: 'Hi! Is this load still available?',
          isRead: true,
          createdAt: now.subtract(const Duration(minutes: 45)),
        ),
        ChatMessageModel(
          id: uuid.v4(),
          chatId: chat1.id,
          senderId: chat1.supplierId,
          messageText: 'Yes, available.',
          isRead: true,
          createdAt: now.subtract(const Duration(minutes: 30)),
        ),
        ChatMessageModel(
          id: uuid.v4(),
          chatId: chat1.id,
          senderId: chat1.truckerId,
          messageText: 'Can you share loading time?',
          isRead: false,
          createdAt: now.subtract(const Duration(minutes: 15)),
        ),
      ],
    );

    await _saveMessages(
      chat2.id,
      [
        ChatMessageModel(
          id: uuid.v4(),
          chatId: chat2.id,
          senderId: chat2.supplierId,
          messageText: 'We can load by tomorrow.',
          isRead: true,
          createdAt: now.subtract(const Duration(hours: 4)),
        ),
        ChatMessageModel(
          id: uuid.v4(),
          chatId: chat2.id,
          senderId: chat2.truckerId,
          messageText: 'Sure, let me confirm.',
          isRead: true,
          createdAt: now.subtract(const Duration(hours: 3)),
        ),
      ],
    );
  }
}
