import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/input_validator.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/chat_model.dart';
import '../models/chat_message_model.dart';
import 'chat_datasource.dart';

class SupabaseChatDataSource implements ChatDataSource {
  final SupabaseClient _supabase;

  SupabaseChatDataSource(this._supabase);

  @override
  Future<List<ChatModel>> getChats({String? userId}) async {
    try {
      Logger.info('💬 SUPABASE: Getting chats');

      var query = _supabase.from('chats').select('*');
      if (userId != null) {
        query = query.or('trucker_id.eq.$userId,supplier_id.eq.$userId');
      }

      final data = await query.order('last_message_at', ascending: false);
      final chats =
          (data as List).map((json) => ChatModel.fromJson(json)).toList();

      Logger.info('✅ SUPABASE: Found ${chats.length} chats');
      return chats;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<List<ChatModel>> watchChats({String? userId}) {
    var query = _supabase
        .from('chats')
        .stream(primaryKey: ['id']).order('last_message_at', ascending: false);

    if (userId != null) {
      // Client-side filtering for complex OR condition in streams
      // Supabase stream filtering is limited compared to select
      return query.map((rows) {
        final chats = rows.map((json) => ChatModel.fromJson(json)).toList();
        return chats
            .where((c) => c.truckerId == userId || c.supplierId == userId)
            .toList();
      });
    }

    return query.map(
      (rows) => rows.map((json) => ChatModel.fromJson(json)).toList(),
    );
  }

  @override
  Future<ChatModel?> getChatById(String chatId) async {
    try {
      final data = await _supabase
          .from('chats')
          .select('*')
          .eq('id', chatId)
          .maybeSingle();

      if (data == null) return null;
      return ChatModel.fromJson(data);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ChatMessageModel>> getMessages(
    String chatId, {
    int limit = 50,
    DateTime? before,
  }) async {
    try {
      Logger.info(
          '💬 SUPABASE: Getting messages for chat $chatId (limit: $limit, before: $before)');

      // Build base query with proper pagination
      var queryBuilder =
          _supabase.from('chat_messages').select('*').eq('chat_id', chatId);

      // Add before filter if provided (for pagination)
      if (before != null) {
        queryBuilder = queryBuilder.lt('created_at', before.toIso8601String());
      }

      // Execute query with ordering and limit
      final response =
          await queryBuilder.order('created_at', ascending: false).limit(limit);

      final messages = (response as List)
          .map((json) => ChatMessageModel.fromJson(json))
          .toList();

      Logger.info('✅ SUPABASE: Retrieved ${messages.length} messages');

      // Reverse to get chronological order (oldest first)
      return messages.reversed.toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<List<ChatMessageModel>> watchMessages(String chatId) {
    return _supabase
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at', ascending: true)
        .map(
          (rows) => rows.map((row) => ChatMessageModel.fromJson(row)).toList(),
        );
  }

  @override
  Future<ChatMessageModel> sendMessage(
    String chatId,
    String senderId,
    String messageText,
  ) async {
    try {
      // Sanitize message to prevent XSS and limit length
      final sanitizedMessage = InputValidator.sanitizeChatMessage(messageText);

      // Check for malicious input
      if (!InputValidator.isSafeInput(sanitizedMessage)) {
        InputValidator.logSuspiciousInput(sanitizedMessage, 'chat_message');
        throw ServerException('Invalid message content');
      }

      Logger.info('💬 SUPABASE: Sending message to chat $chatId');

      final inserted = await _supabase
          .from('chat_messages')
          .insert({
            'chat_id': chatId,
            'sender_id': senderId,
            'message_text': sanitizedMessage,
            'is_read': false,
          })
          .select('*')
          .single();

      Logger.info('✅ SUPABASE: Message sent successfully');
      return ChatMessageModel.fromJson(inserted);
    } catch (e) {
      Logger.error('Failed to send message', error: e);
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markAsRead(String chatId, String userId) async {
    try {
      await _supabase
          .from('chat_messages')
          .update({'is_read': true})
          .eq('chat_id', chatId)
          .neq('sender_id', userId);

      await _supabase
          .from('chats')
          .update({'unread_count': 0}).eq('id', chatId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
