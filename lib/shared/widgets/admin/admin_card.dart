import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Admin-specific card component with consistent glassmorphic styling
class AdminCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool showGlow;
  final AdminCardVariant variant;
  final double? width;
  final double? height;
  final Widget? header;
  final Widget? footer;
  final CrossAxisAlignment alignment;

  const AdminCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.showGlow = false,
    this.variant = AdminCardVariant.default_,
    this.width,
    this.height,
    this.header,
    this.footer,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment,
      children: [
        if (header != null) ...[
          header!,
          const SizedBox(height: AppDimensions.md),
        ],
        child,
        if (footer != null) ...[
          const SizedBox(height: AppDimensions.md),
          footer!,
        ],
      ],
    );

    final card = Container(
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.only(bottom: AppDimensions.md),
      decoration: _getDecoration(),
      child: padding != null
          ? Padding(padding: padding!, child: cardContent)
          : cardContent,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: card,
      );
    }

    return card;
  }

  BoxDecoration _getDecoration() {
    switch (variant) {
      case AdminCardVariant.default_:
        return BoxDecoration(
          color: AppColors.glassSurfaceStrong,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: showGlow
              ? [
                  BoxShadow(
                    color: AppColors.cyanGlow,
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        );
      case AdminCardVariant.elevated:
        return BoxDecoration(
          color: AppColors.glassSurfaceStrong,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.glassBorderStrong),
          boxShadow: [
            BoxShadow(
              color: AppColors.glassShadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            if (showGlow)
              BoxShadow(
                color: AppColors.cyanGlow,
                blurRadius: 8,
                spreadRadius: 1,
              ),
          ],
        );
      case AdminCardVariant.outline:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: showGlow ? AppColors.primary : AppColors.glassBorder,
            width: showGlow ? 2 : 1,
          ),
        );
      case AdminCardVariant.filled:
        return BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.glassBorder.withAlpha((0.5 * 255).round())),
          boxShadow: showGlow
              ? [
                  BoxShadow(
                    color: AppColors.cyanGlow,
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        );
    }
  }
}

/// Admin stat card for displaying metrics
class AdminStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final AdminCardVariant variant;
  final VoidCallback? onTap;

  const AdminStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor = AppColors.primary,
    this.variant = AdminCardVariant.default_,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      variant: variant,
      onTap: onTap,
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.sm),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const Spacer(),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

/// Admin list card for displaying list items
class AdminListCard extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final List<Widget> actions;
  final VoidCallback? onTap;
  final bool showDivider;

  const AdminListCard({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AdminCard(
          onTap: onTap,
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Row(
            children: [
              leading,
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    if (subtitle != null) ...[
                      const SizedBox(height: AppDimensions.xs),
                      subtitle!,
                    ],
                  ],
                ),
              ),
              if (actions.isNotEmpty) ...[
                const SizedBox(width: AppDimensions.md),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions,
                ),
              ],
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: AppColors.glassBorder,
            indent: AppDimensions.lg,
          ),
      ],
    );
  }
}

enum AdminCardVariant {
  default_,
  elevated,
  outline,
  filled,
}

/// Admin card grid for responsive layouts
class AdminCardGrid extends StatelessWidget {
  final List<AdminCard> cards;
  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  const AdminCardGrid({
    super.key,
    required this.cards,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = AppDimensions.md,
    this.mainAxisSpacing = AppDimensions.md,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => cards[index],
    );
  }
}
