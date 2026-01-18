import '../datasources/saved_searches_datasource.dart';
import '../models/saved_search_model.dart';
import '../../../../core/utils/logger.dart';

class SavedSearchesRepository {
  final SavedSearchesDataSource _dataSource;

  SavedSearchesRepository(this._dataSource);

  Future<List<SavedSearchModel>> getSavedSearches(String userId) async {
    try {
      return await _dataSource.getSavedSearches(userId);
    } catch (e) {
      Logger.error('Failed to get saved searches: $e');
      rethrow;
    }
  }

  Future<SavedSearchModel> createSavedSearch(SavedSearchModel search) async {
    try {
      return await _dataSource.createSavedSearch(search);
    } catch (e) {
      Logger.error('Failed to create saved search: $e');
      rethrow;
    }
  }

  Future<void> updateSavedSearch(String id, Map<String, dynamic> updates) async {
    try {
      await _dataSource.updateSavedSearch(id, updates);
    } catch (e) {
      Logger.error('Failed to update saved search: $e');
      rethrow;
    }
  }

  Future<void> deleteSavedSearch(String id) async {
    try {
      await _dataSource.deleteSavedSearch(id);
    } catch (e) {
      Logger.error('Failed to delete saved search: $e');
      rethrow;
    }
  }
}
