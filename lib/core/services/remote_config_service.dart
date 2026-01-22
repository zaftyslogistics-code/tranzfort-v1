import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';

class RemoteConfig {
  final bool enableAds;
  final String minAppVersion;
  final int loadExpiryDays;
  final bool maintenanceMode;
  final String? maintenanceMessage;
  final int maxLoadsPerUser;
  final DateTime updatedAt;

  const RemoteConfig({
    required this.enableAds,
    required this.minAppVersion,
    required this.loadExpiryDays,
    required this.maintenanceMode,
    this.maintenanceMessage,
    required this.maxLoadsPerUser,
    required this.updatedAt,
  });

  factory RemoteConfig.fromJson(Map<String, dynamic> json) {
    return RemoteConfig(
      enableAds: json['enable_ads'] as bool? ?? true,
      minAppVersion: json['min_app_version'] as String? ?? '1.0.0',
      loadExpiryDays: json['load_expiry_days'] as int? ?? 30,
      maintenanceMode: json['maintenance_mode'] as bool? ?? false,
      maintenanceMessage: json['maintenance_message'] as String?,
      maxLoadsPerUser: json['max_loads_per_user'] as int? ?? 50,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  RemoteConfig copyWith({
    bool? enableAds,
    String? minAppVersion,
    int? loadExpiryDays,
    bool? maintenanceMode,
    String? maintenanceMessage,
    int? maxLoadsPerUser,
    DateTime? updatedAt,
  }) {
    return RemoteConfig(
      enableAds: enableAds ?? this.enableAds,
      minAppVersion: minAppVersion ?? this.minAppVersion,
      loadExpiryDays: loadExpiryDays ?? this.loadExpiryDays,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      maintenanceMessage: maintenanceMessage ?? this.maintenanceMessage,
      maxLoadsPerUser: maxLoadsPerUser ?? this.maxLoadsPerUser,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  RemoteConfig? _cachedConfig;
  DateTime? _lastFetch;

  // Cache duration - fetch new config every 5 minutes
  static const Duration _cacheDuration = Duration(minutes: 5);

  // Default fallback config
  static final RemoteConfig _defaultConfig = RemoteConfig(
    enableAds: true,
    minAppVersion: '1.0.0',
    loadExpiryDays: 30,
    maintenanceMode: false,
    maintenanceMessage: null,
    maxLoadsPerUser: 50,
    updatedAt: DateTime.now(),
  );

  /// Get current remote configuration
  /// Returns cached config if available and fresh, otherwise fetches from server
  Future<RemoteConfig> getConfig({bool forceRefresh = false}) async {
    // Return cached config if available and fresh
    if (!forceRefresh &&
        _cachedConfig != null &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < _cacheDuration) {
      return _cachedConfig!;
    }

    try {
      Logger.info('🔧 Fetching remote configuration...');

      final response = await _client
          .from('system_config')
          .select('*')
          .eq('id', 1)
          .maybeSingle();

      if (response == null) {
        Logger.warning('⚠️ No remote config found, using defaults');
        _cachedConfig = _defaultConfig;
        _lastFetch = DateTime.now();
        return _defaultConfig;
      }

      final config = RemoteConfig.fromJson(response);
      _cachedConfig = config;
      _lastFetch = DateTime.now();

      Logger.info('✅ Remote configuration loaded successfully');
      Logger.info('   - Ads enabled: ${config.enableAds}');
      Logger.info('   - Min version: ${config.minAppVersion}');
      Logger.info('   - Maintenance: ${config.maintenanceMode}');

      return config;
    } catch (e) {
      Logger.error('❌ Failed to fetch remote config', error: e);

      // Return cached config if available, otherwise defaults
      if (_cachedConfig != null) {
        Logger.info('📦 Using cached remote configuration');
        return _cachedConfig!;
      } else {
        Logger.info('🔄 Using default remote configuration');
        return _defaultConfig;
      }
    }
  }

  /// Initialize remote config on app start
  /// This should be called early in the app lifecycle
  Future<void> initialize() async {
    try {
      await getConfig(forceRefresh: true);
      Logger.info('🚀 Remote configuration initialized');
    } catch (e) {
      Logger.error('Failed to initialize remote config', error: e);
    }
  }

  /// Check if the app is in maintenance mode
  Future<bool> isMaintenanceMode() async {
    final config = await getConfig();
    return config.maintenanceMode;
  }

  /// Check if ads should be displayed
  Future<bool> areAdsEnabled() async {
    final config = await getConfig();
    return config.enableAds;
  }

  /// Get the minimum required app version
  Future<String> getMinAppVersion() async {
    final config = await getConfig();
    return config.minAppVersion;
  }

  /// Get load expiry days
  Future<int> getLoadExpiryDays() async {
    final config = await getConfig();
    return config.loadExpiryDays;
  }

  /// Get maintenance message
  Future<String?> getMaintenanceMessage() async {
    final config = await getConfig();
    return config.maintenanceMessage;
  }

  /// Get maximum loads per user
  Future<int> getMaxLoadsPerUser() async {
    final config = await getConfig();
    return config.maxLoadsPerUser;
  }

  /// Check if a given app version meets the minimum requirement
  /// Uses semantic versioning comparison (major.minor.patch)
  Future<bool> isVersionSupported(String currentVersion) async {
    final minVersion = await getMinAppVersion();
    return _compareVersions(currentVersion, minVersion) >= 0;
  }

  /// Compare two semantic versions
  /// Returns: -1 if v1 < v2, 0 if v1 == v2, 1 if v1 > v2
  int _compareVersions(String v1, String v2) {
    final v1Parts = v1.split('.').map(int.parse).toList();
    final v2Parts = v2.split('.').map(int.parse).toList();

    // Pad shorter version with zeros
    while (v1Parts.length < 3) {
      v1Parts.add(0);
    }
    while (v2Parts.length < 3) {
      v2Parts.add(0);
    }

    for (int i = 0; i < 3; i++) {
      if (v1Parts[i] < v2Parts[i]) return -1;
      if (v1Parts[i] > v2Parts[i]) return 1;
    }

    return 0;
  }

  /// Clear cached configuration (useful for testing)
  void clearCache() {
    _cachedConfig = null;
    _lastFetch = null;
    Logger.info('🗑️ Remote config cache cleared');
  }

  /// Get cached config without network call (may be null)
  RemoteConfig? getCachedConfig() => _cachedConfig;
}
