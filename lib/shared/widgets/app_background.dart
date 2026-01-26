import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

BoxDecoration appBackgroundDecoration(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  if (isDark) {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.darkBackground,
          AppColors.secondaryBackground,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  return const BoxDecoration(
    gradient: LinearGradient(
      colors: [
        AppColors.lightBackground,
        AppColors.lightSecondary,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
}
