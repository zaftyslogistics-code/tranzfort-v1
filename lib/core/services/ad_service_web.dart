import '../ads/admob_compat.dart';
import '../utils/logger.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool get isInitialized => false;

  String get nativeAdUnitId => '';
  String get bannerAdUnitId => '';

  Future<void> initialize() async {
    Logger.info('📱 AdMob disabled on web');
  }

  NativeAd createNativeAd({
    required Function(Ad ad) onAdLoaded,
    required Function(Ad ad, LoadAdError error) onAdFailedToLoad,
  }) {
    // Return a no-op ad object so call-sites compile; it will never be loaded.
    return NativeAd(
      adUnitId: nativeAdUnitId,
      listener: NativeAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
      request: const AdRequest(),
    );
  }

  BannerAd createBannerAd({
    required Function(Ad ad) onAdLoaded,
    required Function(Ad ad, LoadAdError error) onAdFailedToLoad,
    AdSize size = AdSize.banner,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: size,
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
      request: const AdRequest(),
    );
  }

  void dispose() {}
}
