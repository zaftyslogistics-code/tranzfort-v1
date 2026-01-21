import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/chat_datasource.dart';
import '../../data/datasources/supabase_chat_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/get_chats.dart';
import '../../domain/usecases/get_chat_by_id.dart';
import '../../domain/usecases/get_messages.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/mark_as_read.dart';

final chatDataSourceProvider = Provider<ChatDataSource>((ref) {
  final supabase = Supabase.instance.client;
  return SupabaseChatDataSource(supabase);
});

final chatRepositoryProvider = Provider((ref) {
  final dataSource = ref.watch(chatDataSourceProvider);
  return ChatRepositoryImpl(dataSource);
});

final getChatsUseCaseProvider = Provider((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return GetChats(repository);
});

final getChatByIdUseCaseProvider = Provider((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return GetChatById(repository);
});

final getMessagesUseCaseProvider = Provider((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return GetMessages(repository);
});

final sendMessageUseCaseProvider = Provider((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return SendMessage(repository);
});

final markAsReadUseCaseProvider = Provider((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return MarkAsRead(repository);
});

class ChatState {
  final List<Chat> chats;
  final Chat? selectedChat;
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  ChatState({
    this.chats = const [],
    this.selectedChat,
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<Chat>? chats,
    Chat? selectedChat,
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      chats: chats ?? this.chats,
      selectedChat: selectedChat ?? this.selectedChat,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final Ref _ref;
  final GetChats getChatsUseCase;
  final GetChatById getChatByIdUseCase;
  final GetMessages getMessagesUseCase;
  final SendMessage sendMessageUseCase;
  final MarkAsRead markAsReadUseCase;

  ChatNotifier({
    required Ref ref,
    required this.getChatsUseCase,
    required this.getChatByIdUseCase,
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
    required this.markAsReadUseCase,
  })  : _ref = ref,
        super(ChatState());

  Future<void> fetchChats({String? userId}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await getChatsUseCase(userId: userId);
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (chats) {
        state = state.copyWith(chats: chats, isLoading: false);
      },
    );
  }

  Future<void> selectChat(String chatId) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await getChatByIdUseCase(chatId);
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (chat) {
        state = state.copyWith(selectedChat: chat, isLoading: false);
      },
    );
  }

  Future<void> fetchMessages(String chatId) async {
    final result = await getMessagesUseCase(chatId);
    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (messages) {
        state = state.copyWith(messages: messages);
      },
    );
  }

  Stream<List<ChatMessage>> watchMessages(String chatId) {
    return _ref.read(chatRepositoryProvider).watchMessages(chatId);
  }

  Future<void> sendMessage(
    String chatId,
    String senderId,
    String messageText,
  ) async {
    await sendMessageUseCase(chatId, senderId, messageText);
  }

  Future<void> markAsRead(String chatId, String userId) async {
    await markAsReadUseCase(chatId, userId);
  }
}

final chatNotifierProvider =
    StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(
    ref: ref,
    getChatsUseCase: ref.watch(getChatsUseCaseProvider),
    getChatByIdUseCase: ref.watch(getChatByIdUseCaseProvider),
    getMessagesUseCase: ref.watch(getMessagesUseCaseProvider),
    sendMessageUseCase: ref.watch(sendMessageUseCaseProvider),
    markAsReadUseCase: ref.watch(markAsReadUseCaseProvider),
  );
});

final chatListStreamProvider = StreamProvider.family<List<Chat>, String?>((ref, userId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchChats(userId: userId);
});

final chatMessagesProvider = StreamProvider.family<List<ChatMessage>, String>(
  (ref, chatId) {
    final repository = ref.watch(chatRepositoryProvider);
    return repository.watchMessages(chatId);
  },
);
