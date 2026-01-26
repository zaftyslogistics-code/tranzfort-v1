import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/flat_button.dart';

/// Admin Super Chat Screen v0.02
/// For admin to manage Super Load/Trucker chats with deal/RC actions
class AdminSuperChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String chatType; // 'super_load' or 'super_trucker'

  const AdminSuperChatScreen({
    super.key,
    required this.chatId,
    required this.chatType,
  });

  @override
  ConsumerState<AdminSuperChatScreen> createState() => _AdminSuperChatScreenState();
}

class _AdminSuperChatScreenState extends ConsumerState<AdminSuperChatScreen> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    // TODO: Send message
    _messageController.clear();
  }

  void _markDealDone() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark Deal as Done'),
        content: const Text('Are you sure you want to mark this deal as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Mark deal as done
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Deal marked as done')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _requestRC() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request RC Document'),
        content: const Text('Send a request to the trucker for RC document?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Send RC request
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('RC document requested')),
              );
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Mock chat data
    final chat = {
      'id': widget.chatId,
      'type': widget.chatType,
      'loadId': 'load_123',
      'truckerId': 'trucker_456',
      'truckerName': 'Rajesh Kumar',
      'supplierName': 'ABC Transport Ltd',
      'status': 'active',
    };

    final messages = [
      {
        'id': '1',
        'content': 'Hello, I am interested in this Super Load',
        'senderId': 'trucker_456',
        'senderType': 'trucker',
        'timestamp': '10:30 AM',
      },
      {
        'id': '2',
        'content': 'Great! Please share your RC document',
        'senderId': 'admin_1',
        'senderType': 'admin',
        'timestamp': '10:31 AM',
      },
      {
        'id': '3',
        'content': 'I have uploaded my RC document',
        'senderId': 'trucker_456',
        'senderType': 'trucker',
        'timestamp': '10:35 AM',
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Super ${widget.chatType == 'super_load' ? 'Load' : 'Trucker'} Chat'),
            Text(
              chat['truckerName'] as String,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // TODO: Show chat info
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Load ID: ${chat['loadId']} • ${chat['supplierName']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'Request RC',
                    icon: Icons.description_outlined,
                    onPressed: _requestRC,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    text: 'Mark Deal Done',
                    icon: Icons.check_circle_outline,
                    onPressed: _markDealDone,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isAdmin = message['senderType'] == 'admin';
                final isTrucker = message['senderType'] == 'trucker';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: isAdmin ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!isAdmin) ...[
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isTrucker
                                ? AppColors.primary.withOpacity(0.1)
                                : AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            isTrucker ? Icons.local_shipping : Icons.business,
                            size: 16,
                            color: isTrucker ? AppColors.primary : AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isAdmin
                                ? AppColors.primary
                                : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                            border: Border.all(
                              color: isAdmin
                                  ? AppColors.primary
                                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['content'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isAdmin
                                      ? Colors.white
                                      : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                message['timestamp'] as String,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isAdmin
                                      ? Colors.white.withOpacity(0.7)
                                      : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
