import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/saved_search_model.dart';
import '../../../../core/services/offline_cache_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/retry.dart';

class SavedSearchesDataSource {
  final SupabaseClient _supabase;

  SavedSearchesDataSource(this._supabase);

  Future<List<SavedSearchModel>> getSavedSearches(String userId) async {
    try {
      final response = await retry(
        () => _supabase
            .from('saved_searches')
            .select()
            .eq('user_id', userId)
            .order('created_at', ascending: false),
      );

      final searches = (response as List)
          .map((json) => SavedSearchModel.fromJson(json))
          .toList(growable: false);

      await OfflineCacheService().cacheList(
        OfflineCacheService.savedSearchesKey,
        searches.map((s) => s.toJson()).toList(growable: false),
      );

      return searches;
    } catch (e) {
      Logger.error('Failed to get saved searches: $e');

      final cached = OfflineCacheService().getCachedList(
        OfflineCacheService.savedSearchesKey,
      );
      if (cached != null) {
        return cached
            .map((json) => SavedSearchModel.fromJson(json))
            .toList(growable: false);
      }

      rethrow;
    }
  }

  Future<SavedSearchModel> createSavedSearch(SavedSearchModel search) async {
    try {
      final response = await _supabase
          .from('saved_searches')
          .insert(search.toJson())
          .select()
          .single();

      return SavedSearchModel.fromJson(response);
    } catch (e) {
      Logger.error('Failed to create saved search: $e');
      rethrow;
    }
  }

  Future<void> updateSavedSearch(String id, Map<String, dynamic> updates) async {
    try {
      await _supabase
          .from('saved_searches')
          .update(updates)
          .eq('id', id);
    } catch (e) {
      Logger.error('Failed to update saved search: $e');
      rethrow;
    }
  }

  Future<void> deleteSavedSearch(String id) async {
    try {
      await _supabase
          .from('saved_searches')
          .delete()
          .eq('id', id);
    } catch (e) {
      Logger.error('Failed to delete saved search: $e');
      rethrow;
    }
  }
}
