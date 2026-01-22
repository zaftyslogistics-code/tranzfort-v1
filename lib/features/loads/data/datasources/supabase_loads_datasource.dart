import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/offline_cache_service.dart';
import '../../../../core/utils/retry.dart';
import '../models/load_model.dart';
import '../models/material_type_model.dart';
import '../models/truck_type_model.dart';
import 'loads_datasource.dart';

class SupabaseLoadsDataSource implements LoadsDataSource {
  final SupabaseClient _client;

  SupabaseLoadsDataSource(this._client);

  LoadModel _toLoadModel(Map<String, dynamic> row) {
    return LoadModel.fromJson(row);
  }

  Map<String, dynamic> _toInsertPayload(Map<String, dynamic> loadData) {
    final now = DateTime.now();
    final dynamic loadingDateRaw = loadData['loadingDate'] ?? loadData['loading_date'];

    // Map to database columns - note: DB has both old (material_type, truck_type) 
    // and new (load_type, truck_type_required) columns, but old ones have NOT NULL constraints
    final materialType = loadData['loadType'] ?? loadData['load_type'] ?? loadData['materialType'] ?? loadData['material_type'];
    final truckType = loadData['truckTypeRequired'] ?? loadData['truck_type_required'] ?? loadData['truckType'] ?? loadData['truck_type'];

    return {
      'supplier_id': loadData['supplierId'] ?? loadData['supplier_id'],
      'from_location': loadData['fromLocation'] ?? loadData['from_location'],
      'from_city': loadData['fromCity'] ?? loadData['from_city'],
      'from_state': loadData['fromState'] ?? loadData['from_state'],
      'to_location': loadData['toLocation'] ?? loadData['to_location'],
      'to_city': loadData['toCity'] ?? loadData['to_city'],
      'to_state': loadData['toState'] ?? loadData['to_state'],
      // Map to BOTH old and new columns to satisfy NOT NULL constraints
      'material_type': materialType,
      'truck_type': truckType,
      'load_type': materialType,
      'truck_type_required': truckType,
      'weight': loadData['weight'],
      'weight_in_tons': loadData['weight'], // Also populate old column
      'price': loadData['price'],
      'price_type': loadData['priceType'] ?? loadData['price_type'] ?? 'negotiable',
      'payment_terms': loadData['paymentTerms'] ?? loadData['payment_terms'],
      'loading_date': loadingDateRaw is DateTime
          ? loadingDateRaw.toIso8601String()
          : loadingDateRaw,
      'notes': loadData['notes'],
      'contact_preferences_call':
          loadData['contactPreferencesCall'] ?? loadData['contact_preferences_call'] ?? true,
      'contact_preferences_chat':
          loadData['contactPreferencesChat'] ?? loadData['contact_preferences_chat'] ?? true,
      'expires_at': loadData['expiresAt'] ?? loadData['expires_at'] ?? now.add(const Duration(days: 90)).toIso8601String(),
    };
  }

  Map<String, dynamic> _toUpdatePayload(Map<String, dynamic> updates) {
    // Security: Whitelist allowed fields to prevent malicious updates
    // (e.g. preventing updates to supplier_id, view_count, created_at)
    const allowedFields = {
      'from_location', 'from_city', 'from_state',
      'to_location', 'to_city', 'to_state',
      'load_type', 'truck_type_required',
      'weight', 'price', 'price_type',
      'payment_terms', 'loading_date',
      'notes',
      'contact_preferences_call', 'contact_preferences_chat',
      'status'
    };

    final dynamic loadingDateRaw = updates['loadingDate'] ?? updates['loading_date'];

    final mapped = <String, dynamic>{
      if (updates.containsKey('fromLocation') || updates.containsKey('from_location'))
        'from_location': updates['fromLocation'] ?? updates['from_location'],
      if (updates.containsKey('fromCity') || updates.containsKey('from_city'))
        'from_city': updates['fromCity'] ?? updates['from_city'],
      if (updates.containsKey('fromState') || updates.containsKey('from_state'))
        'from_state': updates['fromState'] ?? updates['from_state'],
      if (updates.containsKey('toLocation') || updates.containsKey('to_location'))
        'to_location': updates['toLocation'] ?? updates['to_location'],
      if (updates.containsKey('toCity') || updates.containsKey('to_city'))
        'to_city': updates['toCity'] ?? updates['to_city'],
      if (updates.containsKey('toState') || updates.containsKey('to_state'))
        'to_state': updates['toState'] ?? updates['to_state'],
      if (updates.containsKey('loadType') || updates.containsKey('load_type'))
        'load_type': updates['loadType'] ?? updates['load_type'],
      if (updates.containsKey('truckTypeRequired') || updates.containsKey('truck_type_required'))
        'truck_type_required': updates['truckTypeRequired'] ?? updates['truck_type_required'],
      if (updates.containsKey('weight')) 'weight': updates['weight'],
      if (updates.containsKey('price')) 'price': updates['price'],
      if (updates.containsKey('priceType') || updates.containsKey('price_type'))
        'price_type': updates['priceType'] ?? updates['price_type'],
      if (updates.containsKey('paymentTerms') || updates.containsKey('payment_terms'))
        'payment_terms': updates['paymentTerms'] ?? updates['payment_terms'],
      if (updates.containsKey('loadingDate') || updates.containsKey('loading_date'))
        'loading_date': loadingDateRaw is DateTime
            ? loadingDateRaw.toIso8601String()
            : loadingDateRaw,
      if (updates.containsKey('notes')) 'notes': updates['notes'],
      if (updates.containsKey('contactPreferencesCall') || updates.containsKey('contact_preferences_call'))
        'contact_preferences_call': updates['contactPreferencesCall'] ?? updates['contact_preferences_call'],
      if (updates.containsKey('contactPreferencesChat') || updates.containsKey('contact_preferences_chat'))
        'contact_preferences_chat': updates['contactPreferencesChat'] ?? updates['contact_preferences_chat'],
      if (updates.containsKey('status')) 'status': updates['status'],
    };

    final sanitized = Map<String, dynamic>.from(mapped)
      ..removeWhere((key, value) => !allowedFields.contains(key));
    
    return sanitized;
  }

  @override
  Future<LoadModel> createLoad(Map<String, dynamic> loadData) async {
    try {
      final payload = _toInsertPayload(loadData);
      final Map<String, dynamic> data =
          await _client.from('loads').insert(payload).select().single();
      
      final load = _toLoadModel(data);
      
      // Update cache
      await OfflineCacheService().addItemToList(
        OfflineCacheService.loadsKey,
        load.toJson(),
      );
      
      return load;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<LoadModel>> getLoads({
    String? status,
    String? supplierId,
    String? searchQuery,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      final data = await retry(() async {
        var query = _client.from('loads').select();

        if (status != null) {
          query = query.eq('status', status);
        }

        if (supplierId != null) {
          query = query.eq('supplier_id', supplierId);
        }

        if (searchQuery != null && searchQuery.isNotEmpty) {
          // Search across multiple fields using OR logic
          // Note: This requires a filter builder string for the OR clause
          final searchFilter = 'from_city.ilike.%$searchQuery%,'
              'to_city.ilike.%$searchQuery%,'
              'from_state.ilike.%$searchQuery%,'
              'to_state.ilike.%$searchQuery%,'
              'truck_type_required.ilike.%$searchQuery%,'
              'load_type.ilike.%$searchQuery%';
          
          query = query.or(searchFilter);
        }

        final from = page * pageSize;
        final to = from + pageSize - 1;

        return await query
            .order('created_at', ascending: false)
            .range(from, to) as List;
      });

      final models = data
          .cast<Map<String, dynamic>>()
          .map(_toLoadModel)
          .toList(growable: false);

      await OfflineCacheService().cacheList(
        OfflineCacheService.loadsKey,
        models.map((m) => m.toJson()).toList(growable: false),
      );

      return models;
    } catch (e) {
      final cached = OfflineCacheService().getCachedList(
        OfflineCacheService.loadsKey,
      );

      if (cached != null) {
        return cached
            .map((json) => LoadModel.fromJson(json))
            .toList(growable: false);
      }

      throw ServerException(e.toString());
    }
  }

  @override
  Future<LoadModel?> getLoadById(String id) async {
    try {
      final Map<String, dynamic>? data = await _client
          .from('loads')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (data == null) return null;
      return _toLoadModel(data);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<LoadModel> updateLoad(String id, Map<String, dynamic> updates) async {
    try {
      final payload = _toUpdatePayload(updates);
      final Map<String, dynamic> data = await _client
          .from('loads')
          .update(payload)
          .eq('id', id)
          .select()
          .single();

      final load = _toLoadModel(data);

      // Update cache
      await OfflineCacheService().updateItemInList(
        OfflineCacheService.loadsKey,
        'id',
        id,
        load.toJson(),
      );

      return load;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteLoad(String id) async {
    try {
      await _client.from('loads').update({'status': 'deleted'}).eq('id', id);
      
      // Update cache
      await OfflineCacheService().removeItemFromList(
        OfflineCacheService.loadsKey,
        'id',
        id,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> incrementViewCount(String id) async {
    try {
      await _client.rpc('increment_load_view_count', params: {'load_id': id});
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<TruckTypeModel>> getTruckTypes() async {
    try {
      final data = await _client.from('truck_types').select('name').order('name')
          as List;

      final names = data
          .cast<Map<String, dynamic>>()
          .map((r) => (r['name'] as String?) ?? '')
          .where((n) => n.isNotEmpty)
          .toList(growable: false);

      return List.generate(
        names.length,
        (i) => TruckTypeModel(
          id: i + 1,
          name: names[i],
          category: null,
          displayOrder: i + 1,
        ),
        growable: false,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<MaterialTypeModel>> getMaterialTypes() async {
    try {
      final data = await _client
          .from('material_types')
          .select('name')
          .order('name') as List;

      final names = data
          .cast<Map<String, dynamic>>()
          .map((r) => (r['name'] as String?) ?? '')
          .where((n) => n.isNotEmpty)
          .toList(growable: false);

      return List.generate(
        names.length,
        (i) => MaterialTypeModel(
          id: i + 1,
          name: names[i],
          category: null,
          displayOrder: i + 1,
        ),
        growable: false,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
