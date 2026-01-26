/// My Trips Provider
/// 
/// Provides trip data for truckers:
/// - Ongoing trips (loads contacted/interested in)
/// - Completed trips
/// - Call history

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Trip data model
class TripData {
  final String id;
  final String loadId;
  final String fromCity;
  final String toCity;
  final String material;
  final double weight;
  final String supplierName;
  final String supplierId;
  final String status;
  final DateTime date;
  final bool hasRated;

  const TripData({
    required this.id,
    required this.loadId,
    required this.fromCity,
    required this.toCity,
    required this.material,
    required this.weight,
    required this.supplierName,
    required this.supplierId,
    required this.status,
    required this.date,
    this.hasRated = false,
  });
}

/// Call history data model
class CallData {
  final String id;
  final String supplierName;
  final String supplierId;
  final String fromCity;
  final String toCity;
  final DateTime callTime;
  final double? rating;

  const CallData({
    required this.id,
    required this.supplierName,
    required this.supplierId,
    required this.fromCity,
    required this.toCity,
    required this.callTime,
    this.rating,
  });
}

/// Provider for ongoing trips (based on chats initiated)
final ongoingTripsProvider = FutureProvider<List<TripData>>((ref) async {
  final user = ref.watch(authNotifierProvider).user;
  if (user == null) return [];

  final supabase = Supabase.instance.client;

  // Get chats where trucker has messaged (indicating interest)
  // Join with loads to get load details
  final response = await supabase
      .from('chats')
      .select('''
        id,
        load_id,
        created_at,
        loads!inner (
          id,
          from_city,
          to_city,
          load_type,
          weight,
          status,
          supplier_id,
          users!loads_supplier_id_fkey (
            name
          )
        )
      ''')
      .eq('trucker_id', user.id)
      .order('created_at', ascending: false);

  final chats = response as List;
  final trips = <TripData>[];

  for (final chat in chats) {
    final load = chat['loads'];
    if (load == null) continue;

    // Only include active/negotiating loads
    final status = load['status'] as String? ?? 'active';
    if (status == 'completed' || status == 'expired') continue;

    final supplierData = load['users'];
    
    trips.add(TripData(
      id: chat['id'] as String,
      loadId: chat['load_id'] as String,
      fromCity: load['from_city'] as String,
      toCity: load['to_city'] as String,
      material: load['load_type'] as String,
      weight: (load['weight'] as num?)?.toDouble() ?? 0,
      supplierName: supplierData?['name'] as String? ?? 'Unknown',
      supplierId: load['supplier_id'] as String,
      status: status == 'booked' ? 'booked' : 'contacted',
      date: DateTime.parse(chat['created_at'] as String),
    ));
  }

  return trips;
});

/// Provider for completed trips
final completedTripsProvider = FutureProvider<List<TripData>>((ref) async {
  final user = ref.watch(authNotifierProvider).user;
  if (user == null) return [];

  final supabase = Supabase.instance.client;

  // Get chats for completed loads
  final response = await supabase
      .from('chats')
      .select('''
        id,
        load_id,
        created_at,
        loads!inner (
          id,
          from_city,
          to_city,
          load_type,
          weight,
          status,
          supplier_id,
          users!loads_supplier_id_fkey (
            name
          )
        )
      ''')
      .eq('trucker_id', user.id)
      .eq('loads.status', 'completed')
      .order('created_at', ascending: false);

  final chats = response as List;
  final trips = <TripData>[];

  // Check if user has rated each supplier
  final ratedSuppliers = <String>{};
  final ratingsResponse = await supabase
      .from('ratings')
      .select('rated_user_id')
      .eq('rater_id', user.id);

  for (final rating in ratingsResponse as List) {
    ratedSuppliers.add(rating['rated_user_id'] as String);
  }

  for (final chat in chats) {
    final load = chat['loads'];
    if (load == null) continue;

    final supplierData = load['users'];
    final supplierId = load['supplier_id'] as String;

    trips.add(TripData(
      id: chat['id'] as String,
      loadId: chat['load_id'] as String,
      fromCity: load['from_city'] as String,
      toCity: load['to_city'] as String,
      material: load['load_type'] as String,
      weight: (load['weight'] as num?)?.toDouble() ?? 0,
      supplierName: supplierData?['name'] as String? ?? 'Unknown',
      supplierId: supplierId,
      status: 'completed',
      date: DateTime.parse(chat['created_at'] as String),
      hasRated: ratedSuppliers.contains(supplierId),
    ));
  }

  return trips;
});

/// Provider for call history
/// Note: This is a placeholder - actual call tracking would require
/// additional infrastructure. For now, we simulate based on load views.
final callHistoryProvider = FutureProvider<List<CallData>>((ref) async {
  final user = ref.watch(authNotifierProvider).user;
  if (user == null) return [];

  final supabase = Supabase.instance.client;

  // Get recent chats as proxy for calls (in real app, track actual calls)
  final response = await supabase
      .from('chats')
      .select('''
        id,
        created_at,
        loads!inner (
          from_city,
          to_city,
          supplier_id,
          users!loads_supplier_id_fkey (
            name
          )
        )
      ''')
      .eq('trucker_id', user.id)
      .order('created_at', ascending: false)
      .limit(20);

  final chats = response as List;
  final calls = <CallData>[];

  // Get ratings given by this user
  final ratingsResponse = await supabase
      .from('ratings')
      .select('rated_user_id, rating')
      .eq('rater_id', user.id);

  final ratings = <String, double>{};
  for (final r in ratingsResponse as List) {
    ratings[r['rated_user_id'] as String] = (r['rating'] as num).toDouble();
  }

  for (final chat in chats) {
    final load = chat['loads'];
    if (load == null) continue;

    final supplierData = load['users'];
    final supplierId = load['supplier_id'] as String;

    calls.add(CallData(
      id: chat['id'] as String,
      supplierName: supplierData?['name'] as String? ?? 'Unknown',
      supplierId: supplierId,
      fromCity: load['from_city'] as String,
      toCity: load['to_city'] as String,
      callTime: DateTime.parse(chat['created_at'] as String),
      rating: ratings[supplierId],
    ));
  }

  return calls;
});
