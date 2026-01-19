import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/data/models/user_model.dart';

class AdminUsersState {
  final List<UserModel> users;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  AdminUsersState({
    this.users = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  AdminUsersState copyWith({
    List<UserModel>? users,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return AdminUsersState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class AdminUsersNotifier extends StateNotifier<AdminUsersState> {
  final SupabaseClient _client;

  AdminUsersNotifier(this._client) : super(AdminUsersState());

  Future<void> fetchUsers({String? query}) async {
    state = state.copyWith(isLoading: true, error: null, searchQuery: query ?? state.searchQuery);

    try {
      var q = _client.from('users').select('*');

      final effectiveQuery = (query ?? state.searchQuery).trim();
      if (effectiveQuery.isNotEmpty) {
        q = q.or(
          'mobile_number.ilike.%$effectiveQuery%,name.ilike.%$effectiveQuery%'
        );
      }

      final data = await q.order('created_at', ascending: false) as List;
      final users = data
          .cast<Map<String, dynamic>>()
          .map(UserModel.fromJson)
          .toList(growable: false);

      state = state.copyWith(isLoading: false, users: users);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> updateUser(String userId, Map<String, dynamic> updates) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updated = await _client
          .from('users')
          .update(updates)
          .eq('id', userId)
          .select('*')
          .single();

      final updatedUser = UserModel.fromJson(updated);
      final next = state.users.map((u) => u.id == userId ? updatedUser : u).toList(growable: false);
      state = state.copyWith(isLoading: false, users: next);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final adminUsersNotifierProvider =
    StateNotifierProvider<AdminUsersNotifier, AdminUsersState>((ref) {
  final client = Supabase.instance.client;
  return AdminUsersNotifier(client);
});
