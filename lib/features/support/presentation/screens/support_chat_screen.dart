import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/flat_button.dart';
import '../../../../shared/widgets/flat_input.dart';

/// Support Chat Screen v0.02
/// For Super Loads/Truckers approval requests
/// Flat design with message bubbles
class SupportChatScreen extends ConsumerStatefulWidget {
  final String? ticketId;
  final String? ticketType; // 'super_load_request', 'super_trucker_request', 'general_support'

  const SupportChatScreen({
    super.key,
    this.ticketId,
    this.ticketType,
  });

  @override
  ConsumerState<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends ConsumerState<SupportChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    // TODO: Send message to backend
    final message = _messageController.text.trim();
    _messageController.clear();

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Mock messages
    final messages = [
      {
        'id': '1',
        'content': 'Hello! How can we help you today?',
        'isAdmin': true,
        'timestamp': '10:30 AM',
      },
      {
        'id': '2',
        'content': 'I would like to get verified for Super Loads access',
        'isAdmin': false,
        'timestamp': '10:31 AM',
      },
      {
        'id': '3',
        'content': 'Great! Please share your bank details and we will verify your account.',
        'isAdmin': true,
        'timestamp': '10:32 AM',
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Support Chat'),
            Text(
              widget.ticketType == 'super_load_request'
                  ? 'Super Loads Request'
                  : widget.ticketType == 'super_trucker_request'
                      ? 'Super Trucker Request'
                      : 'General Support',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Info banner
          if (widget.ticketType != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                border: Border.all(color: AppColors.info),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.info, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.ticketType == 'super_load_request'
                          ? 'Share your bank details to get verified for Super Loads'
                          : 'Our team will review your request and get back to you',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isAdmin = message['isAdmin'] as bool;

                return _MessageBubble(
                  content: message['content'] as String,
                  timestamp: message['timestamp'] as String,
                  isAdmin: isAdmin,
                  isDark: isDark,
                );
              },
            ),
          ),

          // Input area
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
                  child: FlatInput(
                    hint: 'Type a message...',
                    controller: _messageController,
                    maxLines: null,
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _messageController.text.trim().isEmpty
                        ? (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                        : AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _messageController.text.trim().isEmpty
                        ? null
                        : _sendMessage,
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

class _MessageBubble extends StatelessWidget {
  final String content;
  final String timestamp;
  final bool isAdmin;
  final bool isDark;

  const _MessageBubble({
    required this.content,
    required this.timestamp,
    required this.isAdmin,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isAdmin ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isAdmin) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.support_agent,
                size: 16,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isAdmin
                    ? (isDark ? AppColors.darkSurface : AppColors.lightSurface)
                    : AppColors.primary,
                border: Border.all(
                  color: isAdmin
                      ? (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                      : AppColors.primary,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 14,
                      color: isAdmin
                          ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                          : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timestamp,
                    style: TextStyle(
                      fontSize: 10,
                      color: isAdmin
                          ? (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
                          : Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
