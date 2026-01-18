import 'package:equatable/equatable.dart';

class Chat extends Equatable {
  final String id;
  final String loadId;
  final String truckerId;
  final String supplierId;
  final String status;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Chat({
    required this.id,
    required this.loadId,
    required this.truckerId,
    required this.supplierId,
    required this.status,
    this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasUnread => unreadCount > 0;
  bool get isActive => status == 'active';

  @override
  List<Object?> get props => [
        id,
        loadId,
        truckerId,
        supplierId,
        status,
        lastMessage,
        lastMessageAt,
        unreadCount,
      ];
}
