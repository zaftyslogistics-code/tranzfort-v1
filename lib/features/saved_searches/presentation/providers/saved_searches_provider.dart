import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/saved_searches_datasource.dart';
import '../../data/repositories/saved_searches_repository.dart';
import '../../data/models/saved_search_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final savedSearchesDataSourceProvider = Provider<SavedSearchesDataSource>((ref) {
  final supabase = Supabase.instance.client;
  return SavedSearchesDataSource(supabase);
});

final savedSearchesRepositoryProvider = Provider<SavedSearchesRepository>((ref) {
  final ds = ref.watch(savedSearchesDataSourceProvider);
  return SavedSearchesRepository(ds);
});

class SavedSearchesNotifier extends StateNotifier<AsyncValue<List<SavedSearchModel>>> {
  final SavedSearchesRepository _repository;
  final Ref _ref;

  SavedSearchesNotifier(this._repository, this._ref)
      : super(const AsyncValue.loading()) {
    loadSavedSearches();
  }

  Future<void> loadSavedSearches() async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authNotifierProvider).user;
      if (user == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final userId = user.id;
      final searches = await _repository.getSavedSearches(userId);
      state = AsyncValue.data(searches);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> createSavedSearch(SavedSearchModel search) async {
    try {
      await _repository.createSavedSearch(search);
      await loadSavedSearches(); // Reload
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteSavedSearch(String id) async {
    try {
      await _repository.deleteSavedSearch(id);
      await loadSavedSearches();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final savedSearchesProvider = StateNotifierProvider<SavedSearchesNotifier, AsyncValue<List<SavedSearchModel>>>((ref) {
  final repository = ref.watch(savedSearchesRepositoryProvider);
  return SavedSearchesNotifier(repository, ref);
});
