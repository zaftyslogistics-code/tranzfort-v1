import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'analytics_service.dart';
import '../utils/logger.dart';

/// Performance monitoring service for tracking app performance metrics
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final AnalyticsService _analytics = AnalyticsService();
  final Map<String, DateTime> _operationStartTimes = {};
  final Map<String, List<double>> _performanceMetrics = {};

  bool _isInitialized = false;
  Timer? _memoryMonitorTimer;

  /// Initialize performance monitoring
  void initialize() {
    if (_isInitialized) return;

    _isInitialized = true;
    _startMemoryMonitoring();

    Logger.info('📈 Performance monitoring initialized');
  }

  /// Start timing an operation
  void startOperation(String operationName) {
    _operationStartTimes[operationName] = DateTime.now();
  }

  /// End timing an operation and track the duration
  Future<void> endOperation(String operationName,
      {Map<String, dynamic>? metadata}) async {
    final startTime = _operationStartTimes.remove(operationName);
    if (startTime == null) {
      Logger.warning('No start time found for operation: $operationName');
      return;
    }

    final duration =
        DateTime.now().difference(startTime).inMilliseconds.toDouble();

    // Store metric for analysis
    _performanceMetrics.putIfAbsent(operationName, () => []).add(duration);

    // Track in analytics
    await _analytics.trackPerformance(operationName, duration, properties: {
      'operation_type': 'duration_ms',
      'metadata': metadata ?? {},
    });

    Logger.info('⏱️ Operation "$operationName" took ${duration}ms');
  }

  /// Track API call performance
  Future<void> trackApiCall(String endpoint, int statusCode, double durationMs,
      {Map<String, dynamic>? metadata}) async {
    await _analytics
        .trackPerformance('api_call_duration', durationMs, properties: {
      'endpoint': endpoint,
      'status_code': statusCode,
      'operation_type': 'api_call',
      'metadata': metadata ?? {},
    });

    // Track API success/failure rates
    await _analytics.trackEvent('api_call', {
      'endpoint': endpoint,
      'status_code': statusCode,
      'duration_ms': durationMs,
      'success': statusCode >= 200 && statusCode < 300,
    });
  }

  /// Track screen load performance
  Future<void> trackScreenLoad(String screenName, double loadTimeMs,
      {Map<String, dynamic>? metadata}) async {
    await _analytics
        .trackPerformance('screen_load_time', loadTimeMs, properties: {
      'screen_name': screenName,
      'operation_type': 'screen_load',
      'metadata': metadata ?? {},
    });

    Logger.info('📱 Screen "$screenName" loaded in ${loadTimeMs}ms');
  }

  /// Track image processing performance
  Future<void> trackImageProcessing(
      String operation, double durationMs, int fileSizeBytes,
      {Map<String, dynamic>? metadata}) async {
    await _analytics
        .trackPerformance('image_processing_time', durationMs, properties: {
      'operation': operation,
      'file_size_bytes': fileSizeBytes,
      'operation_type': 'image_processing',
      'metadata': metadata ?? {},
    });
  }

  /// Track database query performance
  Future<void> trackDatabaseQuery(String queryType, double durationMs,
      {int? recordCount, Map<String, dynamic>? metadata}) async {
    await _analytics
        .trackPerformance('database_query_time', durationMs, properties: {
      'query_type': queryType,
      'record_count': recordCount,
      'operation_type': 'database_query',
      'metadata': metadata ?? {},
    });
  }

  /// Track cache hit/miss performance
  Future<void> trackCacheOperation(
      String operation, bool hit, double durationMs,
      {Map<String, dynamic>? metadata}) async {
    await _analytics.trackEvent('cache_operation', {
      'operation': operation,
      'cache_hit': hit,
      'duration_ms': durationMs,
      'metadata': metadata ?? {},
    });
  }

  /// Track memory usage (if available)
  Future<void> _trackMemoryUsage() async {
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        // On mobile platforms, we can track basic memory info
        final memoryInfo = await _getMemoryInfo();
        if (memoryInfo != null) {
          await _analytics.trackPerformance(
              'memory_usage_mb', memoryInfo['used_mb']!,
              properties: {
                'total_mb': memoryInfo['total_mb'],
                'available_mb': memoryInfo['available_mb'],
                'operation_type': 'memory_monitoring',
              });
        }
      }
    } catch (e) {
      // Memory monitoring is optional, don't fail if not available
      Logger.warning('Memory monitoring not available: $e');
    }
  }

  /// Get memory information (platform-specific)
  Future<Map<String, double>?> _getMemoryInfo() async {
    try {
      // This is a simplified example - in a real app you might use
      // platform channels to get actual memory information
      return {
        'used_mb': 50.0, // Placeholder values
        'total_mb': 100.0,
        'available_mb': 50.0,
      };
    } catch (e) {
      return null;
    }
  }

  /// Start periodic memory monitoring
  void _startMemoryMonitoring() {
    _memoryMonitorTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _trackMemoryUsage();
    });
  }

  /// Get performance summary for debugging
  Map<String, dynamic> getPerformanceSummary() {
    final summary = <String, dynamic>{};

    for (final entry in _performanceMetrics.entries) {
      final metrics = entry.value;
      if (metrics.isNotEmpty) {
        summary[entry.key] = {
          'count': metrics.length,
          'average_ms': metrics.reduce((a, b) => a + b) / metrics.length,
          'min_ms': metrics.reduce((a, b) => a < b ? a : b),
          'max_ms': metrics.reduce((a, b) => a > b ? a : b),
        };
      }
    }

    return summary;
  }

  /// Clear performance metrics (useful for testing)
  void clearMetrics() {
    _performanceMetrics.clear();
    _operationStartTimes.clear();
    Logger.info('📈 Performance metrics cleared');
  }

  /// Dispose of resources
  void dispose() {
    _memoryMonitorTimer?.cancel();
    _memoryMonitorTimer = null;
    _isInitialized = false;
    Logger.info('📈 Performance monitoring disposed');
  }
}

/// Helper class for easy performance tracking with automatic cleanup
class PerformanceTracker {
  final String _operationName;
  final PerformanceMonitor _monitor;
  final Map<String, dynamic>? _metadata;

  PerformanceTracker._(this._operationName, this._monitor, this._metadata) {
    _monitor.startOperation(_operationName);
  }

  /// Create a new performance tracker
  factory PerformanceTracker.start(String operationName,
      {Map<String, dynamic>? metadata}) {
    return PerformanceTracker._(operationName, PerformanceMonitor(), metadata);
  }

  /// End tracking and record the performance
  Future<void> end() async {
    await _monitor.endOperation(_operationName, metadata: _metadata);
  }
}

/// Extension for easy performance tracking on Future operations
extension PerformanceTrackingFuture<T> on Future<T> {
  /// Track the performance of this Future operation
  Future<T> trackPerformance(String operationName,
      {Map<String, dynamic>? metadata}) async {
    final tracker = PerformanceTracker.start(operationName, metadata: metadata);
    try {
      final result = await this;
      await tracker.end();
      return result;
    } catch (e) {
      await tracker.end();
      rethrow;
    }
  }
}
