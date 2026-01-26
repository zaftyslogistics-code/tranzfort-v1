import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/logger.dart';
import '../providers/auth_provider.dart';

class AdminAccountNotAllowedScreen extends ConsumerStatefulWidget {
  const AdminAccountNotAllowedScreen({super.key});

  @override
  ConsumerState<AdminAccountNotAllowedScreen> createState() =>
      _AdminAccountNotAllowedScreenState();
}

class _AdminAccountNotAllowedScreenState
    extends ConsumerState<AdminAccountNotAllowedScreen> {
  bool _didLogout = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (_didLogout) return;
      _didLogout = true;

      try {
        await ref.read(authNotifierProvider.notifier).logout();
      } catch (e, st) {
        Logger.error('Failed to logout admin session from user app',
            error: e, stackTrace: st);
      }

      if (!mounted) return;
      if (context.mounted) context.go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline,
                  size: 64, color: AppColors.warning),
              const SizedBox(height: AppDimensions.md),
              Text(
                'Admin accounts can\'t use the User app.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.sm),
              Text(
                'Please use the Transfort Admin app to continue.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.lg),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
