import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Admin-specific AppBar component with consistent branding and styling
class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final Widget? leading;
  final VoidCallback? onBackPressed;
  final bool showLogo;
  final String? subtitle;

  const AdminAppBar({
    super.key,
    required this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.leading,
    this.onBackPressed,
    this.showLogo = false,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final border = isDark ? AppColors.glassBorder : AppColors.lightBorder;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            surface,
            surface.withAlpha((0.9 * 255).round()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(
            color: border,
            width: 0.5,
          ),
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: automaticallyImplyLeading,
        leading: leading ??
            (automaticallyImplyLeading && onBackPressed != null
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: onBackPressed,
                    color: onSurface,
                  )
                : null),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showLogo) ...[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryVariant],
                  ),
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.textSecondary
                                : AppColors.lightTextSecondary,
                            fontSize: 12,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: actions?.map((action) {
          return Container(
            margin: const EdgeInsets.only(right: AppDimensions.sm),
            child: action,
          );
        }).toList(),
        centerTitle: false,
        titleSpacing: AppDimensions.md,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Admin AppBar with breadcrumb navigation
class AdminAppBarWithBreadcrumbs extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<BreadcrumbItem> breadcrumbs;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;

  const AdminAppBarWithBreadcrumbs({
    super.key,
    required this.title,
    this.breadcrumbs = const [],
    this.actions,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final border = isDark ? AppColors.glassBorder : AppColors.lightBorder;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            surface,
            surface.withAlpha((0.9 * 255).round()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(
            color: border,
            width: 0.5,
          ),
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (breadcrumbs.isNotEmpty) ...[
              _buildBreadcrumbs(context),
              const SizedBox(height: AppDimensions.xs),
            ],
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
            ),
          ],
        ),
        actions: actions?.map((action) {
          return Container(
            margin: const EdgeInsets.only(right: AppDimensions.sm),
            child: action,
          );
        }).toList(),
        leading: onBackPressed != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: onBackPressed,
                color: onSurface,
              )
            : null,
        centerTitle: false,
        titleSpacing: AppDimensions.md,
      ),
    );
  }

  Widget _buildBreadcrumbs(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: breadcrumbs.asMap().entries.map((entry) {
        final index = entry.key;
        final breadcrumb = entry.value;
        final isLast = index == breadcrumbs.length - 1;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: breadcrumb.onTap,
              child: Text(
                breadcrumb.label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isLast
                          ? (isDark
                              ? AppColors.textPrimary
                              : AppColors.lightTextPrimary)
                          : AppColors.primary,
                      fontSize: 12,
                      fontWeight: isLast ? FontWeight.w500 : FontWeight.normal,
                    ),
              ),
            ),
            if (!isLast) ...[
              const SizedBox(width: AppDimensions.xs),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: isDark
                    ? AppColors.textTertiary
                    : AppColors.lightTextTertiary,
              ),
              const SizedBox(width: AppDimensions.xs),
            ],
          ],
        );
      }).toList(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);
}

class BreadcrumbItem {
  final String label;
  final VoidCallback? onTap;

  const BreadcrumbItem({
    required this.label,
    this.onTap,
  });
}
