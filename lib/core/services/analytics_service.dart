import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';

/// Analytics service for tracking user behavior and app performance
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final SupabaseClient _client = Supabase.instance.client;
  
  bool _isInitialized = false;
  String? _userId;
  String? _sessionId;
  DateTime? _sessionStart;

  /// Initialize analytics service
  Future<void> initialize({String? userId}) async {
    try {
      _userId = userId ?? _client.auth.currentUser?.id;
      _sessionId = _generateSessionId();
      _sessionStart = DateTime.now();
      _isInitialized = true;
      
      Logger.info('📊 Analytics service initialized');
      
      // Track app launch
      await trackEvent('app_launch', {
        'session_id': _sessionId,
        'user_id': _userId,
        'timestamp': _sessionStart?.toIso8601String(),
      });
    } catch (e) {
      Logger.error('Failed to initialize analytics', error: e);
    }
  }

  /// Track custom events
  Future<void> trackEvent(String eventName, Map<String, dynamic> properties) async {
    if (!_isInitialized) {
      Logger.warning('Analytics not initialized, skipping event: $eventName');
      return;
    }

    try {
      final eventData = {
        'event_name': eventName,
        'user_id': _userId,
        'session_id': _sessionId,
        'properties': properties,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _client.from('analytics_events').insert(eventData);
      
      Logger.info('📊 Event tracked: $eventName');
    } catch (e) {
      Logger.error('Failed to track event: $eventName', error: e);
    }
  }

  /// Track screen views
  Future<void> trackScreenView(String screenName, {Map<String, dynamic>? properties}) async {
    await trackEvent('screen_view', {
      'screen_name': screenName,
      'session_duration': _getSessionDuration(),
      ...?properties,
    });
  }

  /// Track user actions
  Future<void> trackUserAction(String action, {Map<String, dynamic>? properties}) async {
    await trackEvent('user_action', {
      'action': action,
      'session_duration': _getSessionDuration(),
      ...?properties,
    });
  }

  /// Track performance metrics
  Future<void> trackPerformance(String metric, double value, {Map<String, dynamic>? properties}) async {
    await trackEvent('performance_metric', {
      'metric_name': metric,
      'metric_value': value,
      'session_duration': _getSessionDuration(),
      ...?properties,
    });
  }

  /// Track errors and crashes
  Future<void> trackError(String error, {String? stackTrace, Map<String, dynamic>? properties}) async {
    await trackEvent('error', {
      'error_message': error,
      'stack_trace': stackTrace,
      'session_duration': _getSessionDuration(),
      ...?properties,
    });
  }

  /// Track feature usage
  Future<void> trackFeatureUsage(String feature, {Map<String, dynamic>? properties}) async {
    await trackEvent('feature_usage', {
      'feature_name': feature,
      'session_duration': _getSessionDuration(),
      ...?properties,
    });
  }

  /// Track business events
  Future<void> trackBusinessEvent(String event, {Map<String, dynamic>? properties}) async {
    await trackEvent('business_event', {
      'business_event': event,
      'session_duration': _getSessionDuration(),
      ...?properties,
    });
  }

  /// Update user ID (when user logs in)
  void setUserId(String userId) {
    _userId = userId;
    Logger.info('📊 Analytics user ID updated: $userId');
  }

  /// Clear user data (when user logs out)
  void clearUser() {
    _userId = null;
    Logger.info('📊 Analytics user data cleared');
  }

  /// End current session
  Future<void> endSession() async {
    if (_sessionStart != null) {
      await trackEvent('session_end', {
        'session_duration': _getSessionDuration(),
        'session_id': _sessionId,
      });
    }
    
    _sessionId = null;
    _sessionStart = null;
    Logger.info('📊 Analytics session ended');
  }

  /// Generate unique session ID
  String _generateSessionId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_userId ?? 'anonymous'}';
  }

  /// Get current session duration in seconds
  int _getSessionDuration() {
    if (_sessionStart == null) return 0;
    return DateTime.now().difference(_sessionStart!).inSeconds;
  }

  /// Get analytics summary for debugging
  Map<String, dynamic> getAnalyticsSummary() {
    return {
      'initialized': _isInitialized,
      'user_id': _userId,
      'session_id': _sessionId,
      'session_start': _sessionStart?.toIso8601String(),
      'session_duration': _getSessionDuration(),
    };
  }
}

/// Predefined analytics events for consistency
class AnalyticsEvents {
  // Authentication events
  static const String loginAttempt = 'login_attempt';
  static const String loginSuccess = 'login_success';
  static const String loginFailure = 'login_failure';
  static const String logout = 'logout';
  
  // Load management events
  static const String loadCreated = 'load_created';
  static const String loadUpdated = 'load_updated';
  static const String loadDeleted = 'load_deleted';
  static const String loadSearched = 'load_searched';
  static const String loadViewed = 'load_viewed';
  
  // Fleet management events
  static const String truckAdded = 'truck_added';
  static const String truckUpdated = 'truck_updated';
  static const String truckDeleted = 'truck_deleted';
  static const String fleetViewed = 'fleet_viewed';
  
  // Chat events
  static const String chatStarted = 'chat_started';
  static const String messageSent = 'message_sent';
  static const String chatViewed = 'chat_viewed';
  
  // Verification events
  static const String verificationStarted = 'verification_started';
  static const String verificationCompleted = 'verification_completed';
  static const String documentsUploaded = 'documents_uploaded';
  
  // Feature usage events
  static const String searchUsed = 'search_used';
  static const String filterApplied = 'filter_applied';
  static const String bookmarkAdded = 'bookmark_added';
  static const String shareUsed = 'share_used';
  
  // Performance events
  static const String appLaunch = 'app_launch';
  static const String screenLoad = 'screen_load';
  static const String apiCall = 'api_call';
  static const String imageUpload = 'image_upload';
  
  // Business events
  static const String loadMatched = 'load_matched';
  static const String contactRevealed = 'contact_revealed';
  static const String adViewed = 'ad_viewed';
  static const String adClicked = 'ad_clicked';
}
