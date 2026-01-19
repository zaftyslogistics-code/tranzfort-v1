import 'package:flutter/widgets.dart';

class AdRequest {
  const AdRequest();
}

class LoadAdError {
  final String message;

  LoadAdError(this.message);
}

class Ad {
  void dispose() {}
}

typedef AdLoadCallback = void Function(Ad ad);
typedef AdFailedToLoadCallback = void Function(Ad ad, LoadAdError error);

class NativeAd extends Ad {
  NativeAd({
    required String adUnitId,
    required NativeAdListener listener,
    required AdRequest request,
    NativeTemplateStyle? nativeTemplateStyle,
  });

  void load() {}
}

class BannerAd extends Ad {
  final AdSize size;

  BannerAd({
    required String adUnitId,
    required AdSize size,
    required BannerAdListener listener,
    required AdRequest request,
  }) : size = size;

  void load() {}
}

class AdSize {
  final int width;
  final int height;

  const AdSize(this.width, this.height);

  static const AdSize banner = AdSize(320, 50);
}

class MobileAds {
  MobileAds._();

  static final MobileAds instance = MobileAds._();

  Future<void> initialize() async {}
}

class NativeAdListener {
  final AdLoadCallback? onAdLoaded;
  final AdFailedToLoadCallback? onAdFailedToLoad;
  final AdLoadCallback? onAdOpened;
  final AdLoadCallback? onAdClosed;
  final AdLoadCallback? onAdImpression;

  NativeAdListener({
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdOpened,
    this.onAdClosed,
    this.onAdImpression,
  });
}

class BannerAdListener {
  final AdLoadCallback? onAdLoaded;
  final AdFailedToLoadCallback? onAdFailedToLoad;
  final AdLoadCallback? onAdOpened;
  final AdLoadCallback? onAdClosed;
  final AdLoadCallback? onAdImpression;

  BannerAdListener({
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdOpened,
    this.onAdClosed,
    this.onAdImpression,
  });
}

class AdWidget extends StatelessWidget {
  final Ad ad;

  const AdWidget({super.key, required this.ad});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

// Template types used by AdService
enum TemplateType { medium }

enum NativeTemplateFontStyle { normal, bold }

class NativeTemplateTextStyle {
  final Color? textColor;
  final Color? backgroundColor;
  final NativeTemplateFontStyle? style;
  final double? size;

  NativeTemplateTextStyle({
    this.textColor,
    this.backgroundColor,
    this.style,
    this.size,
  });
}

class NativeTemplateStyle {
  final TemplateType templateType;
  final Color? mainBackgroundColor;
  final double? cornerRadius;
  final NativeTemplateTextStyle? callToActionTextStyle;
  final NativeTemplateTextStyle? primaryTextStyle;
  final NativeTemplateTextStyle? secondaryTextStyle;
  final NativeTemplateTextStyle? tertiaryTextStyle;

  NativeTemplateStyle({
    required this.templateType,
    this.mainBackgroundColor,
    this.cornerRadius,
    this.callToActionTextStyle,
    this.primaryTextStyle,
    this.secondaryTextStyle,
    this.tertiaryTextStyle,
  });
}
