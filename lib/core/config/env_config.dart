import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'platform/platform_info.dart';

class EnvConfig {
  static String get supabaseUrl {
    final raw = dotenv.env['SUPABASE_URL'] ?? '';
    final web = dotenv.env['SUPABASE_URL_WEB'];
    final android = dotenv.env['SUPABASE_URL_ANDROID'];

    if (isAndroidPlatform && android != null && android.isNotEmpty) {
      return android;
    }

    if (!isAndroidPlatform && web != null && web.isNotEmpty) {
      return web;
    }

    return raw;
  }

  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'local';
  static int get apiTimeout => int.parse(dotenv.env['API_TIMEOUT'] ?? '30000');
  static bool get enableAds => dotenv.env['ENABLE_ADS'] == 'true';
  static bool get enableAnalytics => dotenv.env['ENABLE_ANALYTICS'] == 'true';

  static bool get isProduction => environment == 'production';
  static bool get isStaging => environment == 'staging';
  static bool get isLocal => environment == 'local';

  static String get admobAppId => dotenv.env['ADMOB_APP_ID'] ?? '';
  static String get admobNativeAdUnitId =>
      dotenv.env['ADMOB_NATIVE_AD_UNIT_ID'] ?? '';
  static String get admobBannerAdUnitId =>
      dotenv.env['ADMOB_BANNER_AD_UNIT_ID'] ?? '';

  // AdMob Configuration

  // Free Model Configuration
  static bool get isFreeModel => true; // Always true - payment system removed
}
