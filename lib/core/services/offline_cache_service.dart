import 'dart:convert';
import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
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

  Future<List<Directory>> _candidateBaseDirs() async {
    final dirs = <Directory>[];

    try {
      dirs.add(await getApplicationSupportDirectory());
    } catch (_) {}

    try {
      dirs.add(await getApplicationCacheDirectory());
    } catch (_) {}

    try {
      dirs.add(await getTemporaryDirectory());
    } catch (_) {}

    dirs.add(Directory.systemTemp);

    return dirs;
  }

  Future<void> init() async {
    if (isInitialized) return;

    try {
      final candidates = await _candidateBaseDirs();
      Logger.info(
          '🧠 Offline cache: trying ${candidates.length} candidate directories');

      for (final baseDir in candidates) {
        try {
          final String hivePath =
              '${baseDir.path}${Platform.pathSeparator}transfort${Platform.pathSeparator}hive';

          Logger.info('🧠 Offline cache: trying path: $hivePath');

          final Directory hiveDir = Directory(hivePath);
          if (!await hiveDir.exists()) {
            await hiveDir.create(recursive: true);
          }

          Hive.init(hivePath);
          _box = await Hive.openBox<String>(_boxName);
          Logger.info('✅ Offline cache initialized at: $hivePath');
          return;
        } catch (e) {
          // Try next directory
          Logger.error('Offline cache init attempt failed', error: e);
        }
      }

      Logger.info('⚠️ Offline cache could not be initialized in any directory');
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize offline cache',
          error: e, stackTrace: stackTrace);
      // Don't rethrow - allow app to continue without cache
      Logger.info('⚠️ App will continue without offline cache');
    }
  }

  Future<void> cacheList(String key, List<Map<String, dynamic>> data) async {
    if (!isInitialized) {
      await init();
    }

    if (_box == null) return;

    final encoded = jsonEncode(data);
    await _box!.put(key, encoded);
  }

  List<Map<String, dynamic>>? getCachedList(String key) {
    if (!isInitialized) return null;
    if (_box == null) return null;
    final encoded = _box!.get(key);
    if (encoded == null) return null;

    try {
      final decoded = jsonDecode(encoded) as List<dynamic>;
      return decoded
          .map((entry) => Map<String, dynamic>.from(entry as Map))
          .toList(growable: false);
    } catch (e, st) {
      Logger.error('Failed to decode cached list for key: $key', error: e, stackTrace: st);
      return null;
    }
  }

  Future<void> clearKey(String key) async {
    if (!isInitialized) return;
    if (_box == null) return;
    await _box!.delete(key);
  }

  Future<void> clearAll() async {
    if (!isInitialized) return;
    if (_box == null) return;
    await _box!.clear();
  }

  Future<void> addItemToList(String key, Map<String, dynamic> item) async {
    if (!isInitialized) {
      await init();
    }

    if (_box == null) return;

    final current =
        List<Map<String, dynamic>>.from(getCachedList(key) ?? const []);
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

    if (_box == null) return;

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

    if (_box == null) return;

    final current = getCachedList(key);
    if (current == null) return;

    final mutable = List<Map<String, dynamic>>.from(current);
    mutable.removeWhere((item) => item[idField] == idValue);
    await cacheList(key, mutable);
  }
}
