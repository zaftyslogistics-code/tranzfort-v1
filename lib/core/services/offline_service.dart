import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Offline support service for critical features
/// Caches data locally and queues actions for when online
class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  SharedPreferences? _prefs;
  final List<Map<String, dynamic>> _pendingActions = [];

  // Cache keys
  static const String _cacheKeyMyLoads = 'offline_cache_my_loads';
  static const String _cacheKeyMyTrucks = 'offline_cache_my_trucks';
  static const String _cacheKeyMyProfile = 'offline_cache_my_profile';
  static const String _cacheKeyPendingActions = 'offline_pending_actions';
  static const String _cacheTimestamp = 'offline_cache_timestamp';

  /// Initialize the offline service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadPendingActions();
  }

  /// Cache user's loads for offline access
  Future<void> cacheMyLoads(List<Map<String, dynamic>> loads) async {
    if (_prefs == null) return;

    try {
      await _prefs!.setString(_cacheKeyMyLoads, jsonEncode(loads));
      await _prefs!.setString('${_cacheKeyMyLoads}_$_cacheTimestamp',
          DateTime.now().toIso8601String());

      if (kDebugMode) {
        print('[OFFLINE] Cached ${loads.length} loads');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[OFFLINE] Failed to cache loads: $e');
      }
    }
  }

  /// Get cached loads
  Future<List<Map<String, dynamic>>?> getCachedLoads() async {
    if (_prefs == null) return null;

    try {
      final cached = _prefs!.getString(_cacheKeyMyLoads);
      if (cached == null) return null;

      final timestamp =
          _prefs!.getString('${_cacheKeyMyLoads}_$_cacheTimestamp');
      if (timestamp != null) {
        final cacheTime = DateTime.parse(timestamp);
        final age = DateTime.now().difference(cacheTime);

        // Cache expires after 24 hours
        if (age.inHours > 24) {
          if (kDebugMode) {
            print('[OFFLINE] Cache expired (${age.inHours} hours old)');
          }
          return null;
        }
      }

      final List<dynamic> decoded = jsonDecode(cached);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      if (kDebugMode) {
        print('[OFFLINE] Failed to get cached loads: $e');
      }
      return null;
    }
  }

  /// Cache user's trucks for offline access
  Future<void> cacheMyTrucks(List<Map<String, dynamic>> trucks) async {
    if (_prefs == null) return;

    try {
      await _prefs!.setString(_cacheKeyMyTrucks, jsonEncode(trucks));
      await _prefs!.setString('${_cacheKeyMyTrucks}_$_cacheTimestamp',
          DateTime.now().toIso8601String());

      if (kDebugMode) {
        print('[OFFLINE] Cached ${trucks.length} trucks');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[OFFLINE] Failed to cache trucks: $e');
      }
    }
  }

  /// Get cached trucks
  Future<List<Map<String, dynamic>>?> getCachedTrucks() async {
    if (_prefs == null) return null;

    try {
      final cached = _prefs!.getString(_cacheKeyMyTrucks);
      if (cached == null) return null;

      final timestamp =
          _prefs!.getString('${_cacheKeyMyTrucks}_$_cacheTimestamp');
      if (timestamp != null) {
        final cacheTime = DateTime.parse(timestamp);
        final age = DateTime.now().difference(cacheTime);

        // Cache expires after 24 hours
        if (age.inHours > 24) return null;
      }

      final List<dynamic> decoded = jsonDecode(cached);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      if (kDebugMode) {
        print('[OFFLINE] Failed to get cached trucks: $e');
      }
      return null;
    }
  }

  /// Cache user profile
  Future<void> cacheMyProfile(Map<String, dynamic> profile) async {
    if (_prefs == null) return;

    try {
      await _prefs!.setString(_cacheKeyMyProfile, jsonEncode(profile));

      if (kDebugMode) {
        print('[OFFLINE] Cached user profile');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[OFFLINE] Failed to cache profile: $e');
      }
    }
  }

  /// Get cached profile
  Future<Map<String, dynamic>?> getCachedProfile() async {
    if (_prefs == null) return null;

    try {
      final cached = _prefs!.getString(_cacheKeyMyProfile);
      if (cached == null) return null;

      return jsonDecode(cached) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('[OFFLINE] Failed to get cached profile: $e');
      }
      return null;
    }
  }

  /// Queue an action to be performed when online
  Future<void> queueAction(String type, Map<String, dynamic> data) async {
    final action = {
      'type': type,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    _pendingActions.add(action);
    await _savePendingActions();

    if (kDebugMode) {
      print(
          '[OFFLINE] Queued action: $type (${_pendingActions.length} pending)');
    }
  }

  /// Get all pending actions
  List<Map<String, dynamic>> getPendingActions() {
    return List.from(_pendingActions);
  }

  /// Remove a pending action
  Future<void> removeAction(String actionId) async {
    _pendingActions.removeWhere((action) => action['id'] == actionId);
    await _savePendingActions();

    if (kDebugMode) {
      print(
          '[OFFLINE] Removed action $actionId (${_pendingActions.length} remaining)');
    }
  }

  /// Clear all pending actions
  Future<void> clearPendingActions() async {
    _pendingActions.clear();
    await _savePendingActions();

    if (kDebugMode) {
      print('[OFFLINE] Cleared all pending actions');
    }
  }

  /// Save pending actions to storage
  Future<void> _savePendingActions() async {
    if (_prefs == null) return;

    try {
      await _prefs!
          .setString(_cacheKeyPendingActions, jsonEncode(_pendingActions));
    } catch (e) {
      if (kDebugMode) {
        print('[OFFLINE] Failed to save pending actions: $e');
      }
    }
  }

  /// Load pending actions from storage
  Future<void> _loadPendingActions() async {
    if (_prefs == null) return;

    try {
      final cached = _prefs!.getString(_cacheKeyPendingActions);
      if (cached != null) {
        final List<dynamic> decoded = jsonDecode(cached);
        _pendingActions.clear();
        _pendingActions.addAll(decoded.cast<Map<String, dynamic>>());

        if (kDebugMode) {
          print('[OFFLINE] Loaded ${_pendingActions.length} pending actions');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[OFFLINE] Failed to load pending actions: $e');
      }
    }
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    if (_prefs == null) return;

    try {
      await _prefs!.remove(_cacheKeyMyLoads);
      await _prefs!.remove(_cacheKeyMyTrucks);
      await _prefs!.remove(_cacheKeyMyProfile);
      await _prefs!.remove('${_cacheKeyMyLoads}_$_cacheTimestamp');
      await _prefs!.remove('${_cacheKeyMyTrucks}_$_cacheTimestamp');

      if (kDebugMode) {
        print('[OFFLINE] Cleared all cache');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[OFFLINE] Failed to clear cache: $e');
      }
    }
  }

  /// Check if cache is available
  Future<bool> hasCachedData() async {
    if (_prefs == null) return false;

    return _prefs!.containsKey(_cacheKeyMyLoads) ||
        _prefs!.containsKey(_cacheKeyMyTrucks) ||
        _prefs!.containsKey(_cacheKeyMyProfile);
  }

  /// Get cache age in hours
  Future<int?> getCacheAge() async {
    if (_prefs == null) return null;

    try {
      final timestamp =
          _prefs!.getString('${_cacheKeyMyLoads}_$_cacheTimestamp');
      if (timestamp == null) return null;

      final cacheTime = DateTime.parse(timestamp);
      final age = DateTime.now().difference(cacheTime);
      return age.inHours;
    } catch (e) {
      return null;
    }
  }
}
