import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/analytics_service.dart';

// Provider for AnalyticsService instance
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

// Provider for analytics initialization status
final analyticsInitializedProvider = StateProvider<bool>((ref) => false);

// Analytics helper methods as providers for easy access
class AnalyticsProviders {
  /// Track screen view
  static void trackScreenView(WidgetRef ref, String screenName,
      {Map<String, dynamic>? properties}) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.trackScreenView(screenName, properties: properties);
  }

  /// Track user action
  static void trackUserAction(WidgetRef ref, String action,
      {Map<String, dynamic>? properties}) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.trackUserAction(action, properties: properties);
  }

  /// Track feature usage
  static void trackFeatureUsage(WidgetRef ref, String feature,
      {Map<String, dynamic>? properties}) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.trackFeatureUsage(feature, properties: properties);
  }

  /// Track business event
  static void trackBusinessEvent(WidgetRef ref, String event,
      {Map<String, dynamic>? properties}) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.trackBusinessEvent(event, properties: properties);
  }

  /// Track performance metric
  static void trackPerformance(WidgetRef ref, String metric, double value,
      {Map<String, dynamic>? properties}) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.trackPerformance(metric, value, properties: properties);
  }

  /// Track error
  static void trackError(WidgetRef ref, String error,
      {String? stackTrace, Map<String, dynamic>? properties}) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.trackError(error, stackTrace: stackTrace, properties: properties);
  }
}
