import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';

class AdImpressionTracker {
  final SupabaseClient _supabase;

  AdImpressionTracker(this._supabase);

  /// Track an ad impression in the database
  Future<void> trackImpression({
    required String screenName,
    required String adUnitId,
    required String adType,
    String? userId,
    bool isVerifiedUser = false,
  }) async {
    try {
      await _supabase.from('ads_impressions').insert({
        'user_id': userId,
        'screen_name': screenName,
        'ad_unit_id': adUnitId,
        'ad_type': adType,
        'is_verified_user': isVerifiedUser,
        'shown_at': DateTime.now().toIso8601String(),
      });

      Logger.info('✅ Ad impression tracked: $screenName - $adType');
    } catch (e) {
      Logger.error('❌ Failed to track ad impression: $e');
    }
  }

  /// Check if user should see an ad based on frequency capping
  Future<bool> shouldShowAd({
    required String screenName,
    String? userId,
    int minIntervalMinutes = 5,
  }) async {
    if (userId == null) return true;

    try {
      final result = await _supabase.rpc(
        'should_show_ad',
        params: {
          'p_user_id': userId,
          'p_screen_name': screenName,
          'p_min_interval_minutes': minIntervalMinutes,
        },
      );

      return result as bool;
    } catch (e) {
      Logger.error('❌ Failed to check ad frequency: $e');
      return true; // Default to showing ad on error
    }
  }

  /// Get ad impression count for analytics
  Future<int> getImpressionCount({
    String? userId,
    String? screenName,
    DateTime? since,
  }) async {
    try {
      var query = _supabase.from('ads_impressions').select('*');

      if (userId != null) {
        query = query.eq('user_id', userId);
      }
      if (screenName != null) {
        query = query.eq('screen_name', screenName);
      }
      if (since != null) {
        query = query.gte('shown_at', since.toIso8601String());
      }

      final response = await query;
      return (response as List).length;
    } catch (e) {
      Logger.error('❌ Failed to get impression count: $e');
      return 0;
    }
  }
}
