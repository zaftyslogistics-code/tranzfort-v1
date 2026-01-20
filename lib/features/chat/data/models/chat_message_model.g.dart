// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMessageModelImpl _$$ChatMessageModelImplFromJson(
  Map<String, dynamic> json,
) => _$ChatMessageModelImpl(
  id: json['id'] as String,
  chatId: json['chatId'] as String,
  senderId: json['senderId'] as String,
  messageText: json['messageText'] as String,
  isRead: json['isRead'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$ChatMessageModelImplToJson(
  _$ChatMessageModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'chatId': instance.chatId,
  'senderId': instance.senderId,
  'messageText': instance.messageText,
  'isRead': instance.isRead,
  'createdAt': instance.createdAt.toIso8601String(),
};
