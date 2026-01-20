import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ads/admob_compat.dart';
import '../../core/providers/remote_config_provider.dart';
import '../../core/services/ad_service.dart';
import '../../core/services/ad_impression_tracker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

class NativeAdWidget extends StatefulWidget {
  final String screenName;
  final String? userId;
  final bool isVerifiedUser;
  final AdImpressionTracker? impressionTracker;

  const NativeAdWidget({
    super.key,
    required this.screenName,
    this.userId,
    this.isVerifiedUser = false,
    this.impressionTracker,
  });

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;
  bool _isAdFailed = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final adService = AdService();

    if (!adService.isInitialized) {
      setState(() => _isAdFailed = true);
      return;
    }

    _nativeAd = adService.createNativeAd(
      onAdLoaded: (ad) {
        setState(() {
          _isAdLoaded = true;
        });

        // Track impression
        widget.impressionTracker?.trackImpression(
          screenName: widget.screenName,
          adUnitId: adService.nativeAdUnitId,
          adType: 'native',
          userId: widget.userId,
          isVerifiedUser: widget.isVerifiedUser,
        );
      },
      onAdFailedToLoad: (ad, error) {
        setState(() {
          _isAdFailed = true;
        });
      },
    );

    _nativeAd?.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything if ad failed to load
    if (_isAdFailed) {
      return const SizedBox.shrink();
    }

    // Show loading placeholder while ad is loading
    if (!_isAdLoaded || _nativeAd == null) {
      return _buildLoadingPlaceholder();
    }

    // Show the ad
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: AppColors.glassBorder,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 120,
            maxHeight: 300,
          ),
          child: AdWidget(ad: _nativeAd!),
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: AppColors.glassBorder,
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primary.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              'Loading ad...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
