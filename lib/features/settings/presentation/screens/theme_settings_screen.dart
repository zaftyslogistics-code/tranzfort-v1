import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/flat_card.dart';
import '../providers/theme_provider.dart';

/// Theme Settings Screen v0.02
/// Allows users to choose between System/Light/Dark theme
class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Theme'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Choose your preferred theme',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // System Theme Option
            _ThemeOption(
              title: 'System',
              subtitle: 'Follow device settings',
              icon: Icons.brightness_auto,
              isSelected: themeState.themeMode == AppThemeMode.system,
              onTap: () {
                ref.read(themeProvider.notifier).setThemeMode(AppThemeMode.system);
              },
            ),
            const SizedBox(height: 12),

            // Light Theme Option
            _ThemeOption(
              title: 'Light',
              subtitle: 'Always use light theme',
              icon: Icons.light_mode,
              isSelected: themeState.themeMode == AppThemeMode.light,
              onTap: () {
                ref.read(themeProvider.notifier).setThemeMode(AppThemeMode.light);
              },
            ),
            const SizedBox(height: 12),

            // Dark Theme Option
            _ThemeOption(
              title: 'Dark',
              subtitle: 'Always use dark theme',
              icon: Icons.dark_mode,
              isSelected: themeState.themeMode == AppThemeMode.dark,
              onTap: () {
                ref.read(themeProvider.notifier).setThemeMode(AppThemeMode.dark);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FlatCard(
      onTap: onTap,
      backgroundColor: isSelected
          ? AppColors.primary.withOpacity(0.1)
          : null,
      borderColor: isSelected
          ? AppColors.primary
          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            const Icon(
              Icons.check_circle,
              color: AppColors.primary,
              size: 24,
            ),
        ],
      ),
    );
  }
}
