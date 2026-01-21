import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminAnalyticsState {
  final int dau;
  final int newLoadsToday;
  final double conversionRate;
  final List<int> userGrowthPoints;
  final bool isLoading;
  final String? error;

  AdminAnalyticsState({
    this.dau = 0,
    this.newLoadsToday = 0,
    this.conversionRate = 0.0,
    this.userGrowthPoints = const [],
    this.isLoading = false,
    this.error,
  });

  AdminAnalyticsState copyWith({
    int? dau,
    int? newLoadsToday,
    double? conversionRate,
    List<int>? userGrowthPoints,
    bool? isLoading,
    String? error,
  }) {
    return AdminAnalyticsState(
      dau: dau ?? this.dau,
      newLoadsToday: newLoadsToday ?? this.newLoadsToday,
      conversionRate: conversionRate ?? this.conversionRate,
      userGrowthPoints: userGrowthPoints ?? this.userGrowthPoints,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AdminAnalyticsNotifier extends StateNotifier<AdminAnalyticsState> {
  final SupabaseClient _client;

  AdminAnalyticsNotifier(this._client) : super(AdminAnalyticsState());

  Future<void> fetchAnalytics() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dauCount = await _client.rpc('get_daily_active_users');
      final newLoads = await _client.rpc('get_new_loads_today');
      final conversion = await _client.rpc('get_load_conversion_rate');
      final growthData = await _client.rpc('get_user_growth_last_7_days');

      // Ensure growthData is List<int>
      final List<int> growthList = (growthData as List).map((e) => e as int).toList();

      state = state.copyWith(
        isLoading: false,
        dau: dauCount as int,
        newLoadsToday: newLoads as int,
        conversionRate: (conversion as num).toDouble(),
        userGrowthPoints: growthList,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final adminAnalyticsProvider =
    StateNotifierProvider<AdminAnalyticsNotifier, AdminAnalyticsState>((ref) {
  final client = Supabase.instance.client;
  return AdminAnalyticsNotifier(client);
});
