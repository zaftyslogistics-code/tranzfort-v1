import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/remote_config_provider.dart';
import '../../core/services/ad_impression_tracker.dart';
import 'native_ad_widget.dart';

/// Wrapper widget that conditionally shows ads based on remote configuration
class ConditionalAdWidget extends ConsumerWidget {
  final String screenName;
  final String? userId;
  final bool isVerifiedUser;
  final AdImpressionTracker? impressionTracker;

  const ConditionalAdWidget({
    super.key,
    required this.screenName,
    this.userId,
    this.isVerifiedUser = false,
    this.impressionTracker,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adsEnabled = ref.watch(adsEnabledProvider);

    return adsEnabled.when(
      data: (enabled) {
        if (!enabled) {
          // Ads are disabled via remote config
          return const SizedBox.shrink();
        }

        // Ads are enabled, show the native ad
        return NativeAdWidget(
          screenName: screenName,
          userId: userId,
          isVerifiedUser: isVerifiedUser,
          impressionTracker: impressionTracker,
        );
      },
      loading: () =>
          const SizedBox.shrink(), // Don't show ads while loading config
      error: (_, __) =>
          const SizedBox.shrink(), // Don't show ads on config error
    );
  }
}
