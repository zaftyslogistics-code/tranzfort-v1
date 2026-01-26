/// Supplier Profile Provider
/// 
/// Fetches and aggregates supplier profile data including:
/// - Basic info from users table
/// - Ratings from ratings table
/// - Operating routes from loads history
/// - Products handled from loads history
/// - Active loads

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../loads/domain/entities/load.dart';

/// Supplier profile data model
class SupplierProfile {
  final String id;
  final String name;
  final String? fullName;
  final String? location;
  final String? phone;
  final bool isVerified;
  final double? rating;
  final int? ratingCount;
  final int? paymentScore;
  final int? serviceScore;
  final List<String> operatingRoutes;
  final List<String> productsHandled;
  final List<Load> activeLoads;

  const SupplierProfile({
    required this.id,
    required this.name,
    this.fullName,
    this.location,
    this.phone,
    this.isVerified = false,
    this.rating,
    this.ratingCount,
    this.paymentScore,
    this.serviceScore,
    this.operatingRoutes = const [],
    this.productsHandled = const [],
    this.activeLoads = const [],
  });
}

/// Provider to fetch supplier profile
final supplierProfileProvider = FutureProvider.family<SupplierProfile, String>(
  (ref, supplierId) async {
    final supabase = Supabase.instance.client;

    // Fetch user data
    final userResponse = await supabase
        .from('users')
        .select('id, name, email, phone, city, state, supplier_verification_status')
        .eq('id', supplierId)
        .single();

    final userData = userResponse;
    final isVerified = userData['supplier_verification_status'] == 'verified';
    final location = [
      userData['city'] as String?,
      userData['state'] as String?,
    ].where((s) => s != null && s.isNotEmpty).join(', ');

    // Fetch ratings
    final ratingsResponse = await supabase
        .from('ratings')
        .select('rating, payment_good, service_good')
        .eq('rated_user_id', supplierId);

    final ratings = ratingsResponse as List;
    double? avgRating;
    int? ratingCount;
    int? paymentScore;
    int? serviceScore;

    if (ratings.isNotEmpty) {
      ratingCount = ratings.length;
      final totalRating = ratings.fold<double>(
        0,
        (sum, r) => sum + (r['rating'] as num).toDouble(),
      );
      avgRating = totalRating / ratingCount;

      // Calculate payment and service scores
      final paymentGoodCount = ratings.where((r) => r['payment_good'] == true).length;
      final serviceGoodCount = ratings.where((r) => r['service_good'] == true).length;
      paymentScore = ((paymentGoodCount / ratingCount) * 100).round();
      serviceScore = ((serviceGoodCount / ratingCount) * 100).round();
    }

    // Fetch loads for routes and products
    final loadsResponse = await supabase
        .from('loads')
        .select('id, from_city, to_city, load_type, status, from_location, to_location, from_state, to_state, truck_type_required, weight, price, price_type, rate_per_ton, advance_required, advance_percent, loading_date, notes, contact_preferences_call, contact_preferences_chat, expires_at, view_count, chat_count, is_super_load, created_at, updated_at, supplier_id')
        .eq('supplier_id', supplierId)
        .order('created_at', ascending: false);

    final loads = (loadsResponse as List).map((json) {
      return Load(
        id: json['id'] as String,
        supplierId: json['supplier_id'] as String,
        fromLocation: json['from_location'] as String,
        fromCity: json['from_city'] as String,
        fromState: json['from_state'] as String?,
        toLocation: json['to_location'] as String,
        toCity: json['to_city'] as String,
        toState: json['to_state'] as String?,
        loadType: json['load_type'] as String,
        truckTypeRequired: json['truck_type_required'] as String,
        weight: (json['weight'] as num?)?.toDouble(),
        price: (json['price'] as num?)?.toDouble(),
        priceType: json['price_type'] as String? ?? 'negotiable',
        ratePerTon: (json['rate_per_ton'] as num?)?.toDouble(),
        advanceRequired: json['advance_required'] as bool? ?? true,
        advancePercent: json['advance_percent'] as int? ?? 70,
        loadingDate: json['loading_date'] != null
            ? DateTime.parse(json['loading_date'] as String)
            : null,
        notes: json['notes'] as String?,
        contactPreferencesCall: json['contact_preferences_call'] as bool? ?? true,
        contactPreferencesChat: json['contact_preferences_chat'] as bool? ?? true,
        status: json['status'] as String? ?? 'active',
        expiresAt: DateTime.parse(json['expires_at'] as String),
        viewCount: json['view_count'] as int? ?? 0,
        chatCount: json['chat_count'] as int? ?? 0,
        isSuperLoad: json['is_super_load'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
    }).toList();

    // Extract unique routes
    final routes = <String>{};
    for (final load in loads) {
      routes.add('${load.fromCity} - ${load.toCity}');
    }

    // Extract unique products
    final products = <String>{};
    for (final load in loads) {
      products.add(load.loadType);
    }

    // Filter active loads
    final activeLoads = loads.where((l) => l.status == 'active').toList();

    return SupplierProfile(
      id: supplierId,
      name: userData['name'] as String? ?? 'Unknown',
      fullName: userData['name'] as String?,
      location: location.isEmpty ? null : location,
      phone: userData['phone'] as String?,
      isVerified: isVerified,
      rating: avgRating,
      ratingCount: ratingCount,
      paymentScore: paymentScore,
      serviceScore: serviceScore,
      operatingRoutes: routes.toList(),
      productsHandled: products.toList(),
      activeLoads: activeLoads,
    );
  },
);
