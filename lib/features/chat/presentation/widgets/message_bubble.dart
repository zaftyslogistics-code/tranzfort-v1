import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final Color bubbleColor = isMe
        ? AppColors.primary.withAlpha((0.9 * 255).round())
        : AppColors.glassSurfaceStrong;

    final Color borderColor = isMe
        ? AppColors.primaryVariant.withAlpha((0.6 * 255).round())
        : AppColors.glassBorder;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppDimensions.xxs),
        padding: const EdgeInsets.all(AppDimensions.sm),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: borderColor),
          boxShadow: [
            const BoxShadow(
              color: AppColors.glassShadow,
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
            if (isMe)
              const BoxShadow(
                color: AppColors.cyanGlowStrong,
                blurRadius: 18,
                spreadRadius: 1,
                offset: Offset(0, 0),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.messageText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        isMe ? AppColors.darkOnSurface : AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: AppDimensions.xxs),
            Text(
              Formatters.formatTime(message.createdAt),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isMe
                        ? AppColors.textSecondary
                        : AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
