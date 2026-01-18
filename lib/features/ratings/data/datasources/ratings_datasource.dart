import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/rating_model.dart';
import '../../../../core/utils/logger.dart';

class RatingsDataSource {
  final SupabaseClient _supabase;

  RatingsDataSource(this._supabase);

  Future<List<RatingModel>> getRatingsForUser(String userId) async {
    try {
      final response = await _supabase
          .from('ratings')
          .select()
          .eq('rated_user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => RatingModel.fromJson(json))
          .toList();
    } catch (e) {
      Logger.error('Failed to get ratings: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserRatingStats(String userId) async {
    try {
      final response = await _supabase
          .rpc('get_user_rating_stats', params: {'p_user_id': userId});

      return response as Map<String, dynamic>;
    } catch (e) {
      Logger.error('Failed to get rating stats: $e');
      return {
        'average_rating': 0.0,
        'total_ratings': 0,
        'rating_breakdown': {},
      };
    }
  }

  Future<RatingModel> createRating(RatingModel rating) async {
    try {
      final response = await _supabase
          .from('ratings')
          .insert(rating.toJson())
          .select()
          .single();

      return RatingModel.fromJson(response);
    } catch (e) {
      Logger.error('Failed to create rating: $e');
      rethrow;
    }
  }

  Future<void> updateRating(String id, Map<String, dynamic> updates) async {
    try {
      await _supabase
          .from('ratings')
          .update(updates)
          .eq('id', id);
    } catch (e) {
      Logger.error('Failed to update rating: $e');
      rethrow;
    }
  }

  Future<bool> hasUserRatedLoad(String raterUserId, String loadId) async {
    try {
      final response = await _supabase
          .from('ratings')
          .select()
          .eq('rater_user_id', raterUserId)
          .eq('load_id', loadId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      Logger.error('Failed to check rating: $e');
      return false;
    }
  }
}
