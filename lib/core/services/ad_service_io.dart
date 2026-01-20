import 'dart:io';
import 'package:flutter/material.dart';
import '../ads/admob_compat.dart';
import '../utils/logger.dart';
import '../config/env_config.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  static String get _testNativeAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/2247696110'
      : 'ca-app-pub-3940256099942544/3986624511';

  static String get _testBannerAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  String get nativeAdUnitId => EnvConfig.admobNativeAdUnitId ?? _testNativeAdUnitId;
  String get bannerAdUnitId => EnvConfig.admobBannerAdUnitId ?? _testBannerAdUnitId;

  Future<void> initialize() async {
    if (_isInitialized) {
      Logger.info('📱 AdMob already initialized');
      return;
    }

    // Only initialize on Android/iOS
    if (!Platform.isAndroid && !Platform.isIOS) {
      Logger.info('📱 AdMob skipped on non-mobile platform');
      _isInitialized = false;
      return;
    }

    try {
      Logger.info('📱 Initializing AdMob...');
      await MobileAds.instance.initialize();
      _isInitialized = true;
      Logger.info('✅ AdMob initialized successfully');
    } catch (e) {
      Logger.error('❌ Failed to initialize AdMob: $e');
    }
  }

  NativeAd createNativeAd({
    required Function(Ad ad) onAdLoaded,
    required Function(Ad ad, LoadAdError error) onAdFailedToLoad,
  }) {
    return NativeAd(
      adUnitId: nativeAdUnitId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          Logger.info('✅ Native ad loaded');
          onAdLoaded(ad);
        },
        onAdFailedToLoad: (ad, error) {
          Logger.error('❌ Native ad failed to load: ${error.message}');
          ad.dispose();
          onAdFailedToLoad(ad, error);
        },
        onAdOpened: (ad) {
          Logger.info('📱 Native ad opened');
        },
        onAdClosed: (ad) {
          Logger.info('📱 Native ad closed');
        },
        onAdImpression: (ad) {
          Logger.info('👁️ Native ad impression recorded');
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: const Color(0xFF0A0F24),
        cornerRadius: 12.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: const Color(0xFF00B3B3),
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: const Color(0xFFF8F9FB),
          style: NativeTemplateFontStyle.normal,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: const Color(0xFF9BA5B8),
          style: NativeTemplateFontStyle.normal,
          size: 14.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: const Color(0xFF9BA5B8),
          style: NativeTemplateFontStyle.normal,
          size: 12.0,
        ),
      ),
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
        onAdLoaded: (ad) {
          Logger.info('✅ Banner ad loaded');
          onAdLoaded(ad);
        },
        onAdFailedToLoad: (ad, error) {
          Logger.error('❌ Banner ad failed to load: ${error.message}');
          ad.dispose();
          onAdFailedToLoad(ad, error);
        },
        onAdOpened: (ad) {
          Logger.info('📱 Banner ad opened');
        },
        onAdClosed: (ad) {
          Logger.info('📱 Banner ad closed');
        },
        onAdImpression: (ad) {
          Logger.info('👁️ Banner ad impression recorded');
        },
      ),
      request: const AdRequest(),
    );
  }

  void dispose() {
    _isInitialized = false;
  }
}
