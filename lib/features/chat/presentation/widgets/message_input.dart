import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isSending;

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.isSending = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.sm,
        AppDimensions.xs,
        AppDimensions.sm,
        AppDimensions.sm,
      ),
      child: GlassmorphicCard(
        blur: 10,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.sm,
          vertical: AppDimensions.xs,
        ),
        borderRadius: AppDimensions.radiusLg,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                maxLength: 1000,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                  counterText: '',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            IconButton(
              onPressed: isSending ? null : onSend,
              icon: const Icon(Icons.send),
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
