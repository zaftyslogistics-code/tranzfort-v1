import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../domain/entities/chat.dart';

class ChatPreviewCard extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;

  const ChatPreviewCard({
    super.key,
    required this.chat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.xs,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: GlassmorphicCard(
          padding: const EdgeInsets.all(AppDimensions.md),
          borderRadius: AppDimensions.radiusMd,
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.glassSurfaceStrong,
                child: Icon(
                  Icons.local_shipping_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Load #${chat.loadId.substring(0, 6)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chat.lastMessage ?? 'Start conversation',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (chat.lastMessageAt != null)
                    Text(
                      Formatters.timeAgo(chat.lastMessageAt!),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  if (chat.unreadCount > 0) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.sm,
                        vertical: AppDimensions.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusSm),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.cyanGlowStrong,
                            blurRadius: 14,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Text(
                        chat.unreadCount.toString(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.darkOnSurface,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
