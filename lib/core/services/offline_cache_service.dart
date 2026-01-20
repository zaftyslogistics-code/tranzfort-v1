import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import '../utils/logger.dart';

class OfflineCacheService {
  static final OfflineCacheService _instance = OfflineCacheService._internal();
  factory OfflineCacheService() => _instance;
  OfflineCacheService._internal();

  static const String _boxName = 'transfort_cache';
  static const String loadsKey = 'cached_loads';
  static const String savedSearchesKey = 'cached_saved_searches';
  static const String notificationsKey = 'cached_notifications';

  Box<String>? _box;

  bool get isInitialized => _box != null;

  Future<void> init() async {
    if (isInitialized) return;
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
    Logger.info('✅ Offline cache initialized');
  }

  Future<void> cacheList(String key, List<Map<String, dynamic>> data) async {
    if (!isInitialized) {
      await init();
    }

    final encoded = jsonEncode(data);
    await _box!.put(key, encoded);
  }

  List<Map<String, dynamic>>? getCachedList(String key) {
    if (!isInitialized) return null;
    final encoded = _box!.get(key);
    if (encoded == null) return null;

    try {
      final decoded = jsonDecode(encoded) as List<dynamic>;
      return decoded
          .map((entry) => Map<String, dynamic>.from(entry as Map))
          .toList(growable: false);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearKey(String key) async {
    if (!isInitialized) return;
    await _box!.delete(key);
  }

  Future<void> clearAll() async {
    if (!isInitialized) return;
    await _box!.clear();
  }

  Future<void> addItemToList(String key, Map<String, dynamic> item) async {
    if (!isInitialized) {
      await init();
    }

    final current = List<Map<String, dynamic>>.from(getCachedList(key) ?? const []);
    current.insert(0, item);
    await cacheList(key, current);
  }

  Future<void> updateItemInList(
    String key,
    String idField,
    String idValue,
    Map<String, dynamic> updates,
  ) async {
    if (!isInitialized) {
      await init();
    }

    final current = getCachedList(key);
    if (current == null) return;

    final mutable = List<Map<String, dynamic>>.from(current);
    final index = mutable.indexWhere((item) => item[idField] == idValue);
    if (index == -1) return;

    mutable[index] = {
      ...mutable[index],
      ...updates,
    };
    await cacheList(key, mutable);
  }

  Future<void> removeItemFromList(
    String key,
    String idField,
    String idValue,
  ) async {
    if (!isInitialized) {
      await init();
    }

    final current = getCachedList(key);
    if (current == null) return;

    final mutable = List<Map<String, dynamic>>.from(current);
    mutable.removeWhere((item) => item[idField] == idValue);
    await cacheList(key, mutable);
  }
}
