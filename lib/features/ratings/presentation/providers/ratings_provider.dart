import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/ratings_datasource.dart';
import '../../data/models/rating_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final ratingsDataSourceProvider = Provider<RatingsDataSource>((ref) {
  final supabase = Supabase.instance.client;
  return RatingsDataSource(supabase);
});

final myRatingsProvider = FutureProvider<List<RatingModel>>((ref) async {
  final user = ref.watch(authNotifierProvider).user;
  if (user == null) return [];

  final ds = ref.watch(ratingsDataSourceProvider);
  return ds.getRatingsForUser(user.id);
});
