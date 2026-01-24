import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message_model.freezed.dart';
part 'chat_message_model.g.dart';

@freezed
class ChatMessageModel with _$ChatMessageModel {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ChatMessageModel({
    required String id,
    required String chatId,
    required String senderId,
    required String messageText,
    @Default(false) bool isRead,
    required DateTime createdAt,
  }) = _ChatMessageModel;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageModelFromJson(json);
}
