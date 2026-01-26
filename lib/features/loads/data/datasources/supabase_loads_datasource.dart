import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/offline_cache_service.dart';
import '../../../../core/utils/logger.dart';
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
    final dynamic loadingDateRaw =
        loadData['loadingDate'] ?? loadData['loading_date'];

    final dynamic priceTypeRaw = loadData['priceType'] ?? loadData['price_type'];
    final priceTypeStr = (priceTypeRaw is String ? priceTypeRaw : 'negotiable').trim();
    final dynamic ratePerTonRaw = loadData['ratePerTon'] ?? loadData['rate_per_ton'];
    final dynamic advanceRequiredRaw =
        loadData['advanceRequired'] ?? loadData['advance_required'];
    final dynamic advancePercentRaw =
        loadData['advancePercent'] ?? loadData['advance_percent'];

    final dynamic isSuperLoadRaw =
        loadData['isSuperLoad'] ?? loadData['is_super_load'];
    final dynamic postedByAdminIdRaw =
        loadData['postedByAdminId'] ?? loadData['posted_by_admin_id'];

    // Map to database columns - note: DB has both old (material_type, truck_type)
    // and new (load_type, truck_type_required) columns, but old ones have NOT NULL constraints
    final materialType = loadData['loadType'] ??
        loadData['load_type'] ??
        loadData['materialType'] ??
        loadData['material_type'];
    final truckType = loadData['truckTypeRequired'] ??
        loadData['truck_type_required'] ??
        loadData['truckType'] ??
        loadData['truck_type'];

    final supplierId = loadData['supplierId'] ?? loadData['supplier_id'];
    final fromCity = loadData['fromCity'] ?? loadData['from_city'];
    final toCity = loadData['toCity'] ?? loadData['to_city'];

    final fromState = loadData['fromState'] ?? loadData['from_state'];
    final toState = loadData['toState'] ?? loadData['to_state'];

    final materialTypeStr = materialType is String ? materialType.trim() : '';
    final truckTypeStr = truckType is String ? truckType.trim() : '';
    final fromStateStr = fromState is String ? fromState.trim() : '';
    final toStateStr = toState is String ? toState.trim() : '';
    final supplierIdStr = supplierId is String ? supplierId.trim() : '';
    final fromCityStr = fromCity is String ? fromCity.trim() : '';
    final toCityStr = toCity is String ? toCity.trim() : '';

    Logger.info(
      '🧾 LOAD INSERT: material=${materialTypeStr.isEmpty ? 0 : 1} truck=${truckTypeStr.isEmpty ? 0 : 1} fromState=${fromStateStr.isEmpty ? 0 : 1} toState=${toStateStr.isEmpty ? 0 : 1}',
    );

    if (materialTypeStr.isEmpty || truckTypeStr.isEmpty) {
      throw ServerException(
          'Missing material type or truck type. Please re-check Step 1 selections.');
    }

    if (supplierIdStr.isEmpty) {
      throw ServerException('Missing supplier session. Please log in again.');
    }

    if (fromCityStr.isEmpty || toCityStr.isEmpty) {
      throw ServerException(
          'Missing pickup/drop city. Please fill in both cities and try again.');
    }

    if (fromStateStr.isEmpty || toStateStr.isEmpty) {
      throw ServerException(
          'Missing pickup/drop state. Please fill in both states and try again.');
    }

    if (priceTypeStr == 'per_ton') {
      final double? rate = ratePerTonRaw is num
          ? ratePerTonRaw.toDouble()
          : double.tryParse(ratePerTonRaw?.toString() ?? '');
      if (rate == null || rate <= 0) {
        throw ServerException('Enter a valid rate per ton.');
      }
    }

    return {
      'supplier_id': supplierIdStr,
      if (isSuperLoadRaw != null) 'is_super_load': isSuperLoadRaw,
      if (postedByAdminIdRaw != null) 'posted_by_admin_id': postedByAdminIdRaw,
      'from_location': loadData['fromLocation'] ?? loadData['from_location'],
      'from_city': fromCityStr,
      'from_state': fromStateStr,
      'from_lat': loadData['fromLat'] ?? loadData['from_lat'],
      'from_lng': loadData['fromLng'] ?? loadData['from_lng'],
      'to_location': loadData['toLocation'] ?? loadData['to_location'],
      'to_city': toCityStr,
      'to_state': toStateStr,
      'to_lat': loadData['toLat'] ?? loadData['to_lat'],
      'to_lng': loadData['toLng'] ?? loadData['to_lng'],
      // Map to BOTH old and new columns to satisfy NOT NULL constraints
      'material_type': materialTypeStr,
      'truck_type': truckTypeStr,
      'load_type': materialTypeStr,
      'truck_type_required': truckTypeStr,
      'weight': loadData['weight'],
      'weight_in_tons': loadData['weight'], // Also populate old column
      'price': loadData['price'],
      'price_type': priceTypeStr.isEmpty ? 'negotiable' : priceTypeStr,
      'rate_per_ton': ratePerTonRaw,
      'advance_required': advanceRequiredRaw,
      'advance_percent': advancePercentRaw,
      'payment_terms': loadData['paymentTerms'] ?? loadData['payment_terms'],
      'loading_date': loadingDateRaw is DateTime
          ? loadingDateRaw.toIso8601String()
          : loadingDateRaw,
      'notes': loadData['notes'],
      'contact_preferences_call': loadData['contactPreferencesCall'] ??
          loadData['contact_preferences_call'] ??
          true,
      'contact_preferences_chat': loadData['contactPreferencesChat'] ??
          loadData['contact_preferences_chat'] ??
          true,
      'expires_at': loadData['expiresAt'] ??
          loadData['expires_at'] ??
          now.add(const Duration(days: 90)).toIso8601String(),
    };
  }

  Map<String, dynamic> _toUpdatePayload(Map<String, dynamic> updates) {
    // Security: Whitelist allowed fields to prevent malicious updates
    // (e.g. preventing updates to supplier_id, view_count, created_at)
    const allowedFields = {
      'from_location',
      'from_city',
      'from_state',
      'from_lat',
      'from_lng',
      'to_location',
      'to_city',
      'to_state',
      'to_lat',
      'to_lng',
      'load_type',
      'truck_type_required',
      'weight',
      'price',
      'price_type',
      'rate_per_ton',
      'advance_required',
      'advance_percent',
      'payment_terms',
      'loading_date',
      'notes',
      'contact_preferences_call',
      'contact_preferences_chat',
      'status'
    };

    final dynamic loadingDateRaw =
        updates['loadingDate'] ?? updates['loading_date'];

    final mapped = <String, dynamic>{
      if (updates.containsKey('fromLocation') ||
          updates.containsKey('from_location'))
        'from_location': updates['fromLocation'] ?? updates['from_location'],
      if (updates.containsKey('fromCity') || updates.containsKey('from_city'))
        'from_city': updates['fromCity'] ?? updates['from_city'],
      if (updates.containsKey('fromState') || updates.containsKey('from_state'))
        'from_state': updates['fromState'] ?? updates['from_state'],
      if (updates.containsKey('fromLat') || updates.containsKey('from_lat'))
        'from_lat': updates['fromLat'] ?? updates['from_lat'],
      if (updates.containsKey('fromLng') || updates.containsKey('from_lng'))
        'from_lng': updates['fromLng'] ?? updates['from_lng'],
      if (updates.containsKey('toLocation') ||
          updates.containsKey('to_location'))
        'to_location': updates['toLocation'] ?? updates['to_location'],
      if (updates.containsKey('toCity') || updates.containsKey('to_city'))
        'to_city': updates['toCity'] ?? updates['to_city'],
      if (updates.containsKey('toState') || updates.containsKey('to_state'))
        'to_state': updates['toState'] ?? updates['to_state'],
      if (updates.containsKey('toLat') || updates.containsKey('to_lat'))
        'to_lat': updates['toLat'] ?? updates['to_lat'],
      if (updates.containsKey('toLng') || updates.containsKey('to_lng'))
        'to_lng': updates['toLng'] ?? updates['to_lng'],
      if (updates.containsKey('loadType') || updates.containsKey('load_type'))
        'load_type': updates['loadType'] ?? updates['load_type'],
      if (updates.containsKey('truckTypeRequired') ||
          updates.containsKey('truck_type_required'))
        'truck_type_required':
            updates['truckTypeRequired'] ?? updates['truck_type_required'],
      if (updates.containsKey('weight')) 'weight': updates['weight'],
      if (updates.containsKey('price')) 'price': updates['price'],
      if (updates.containsKey('priceType') || updates.containsKey('price_type'))
        'price_type': updates['priceType'] ?? updates['price_type'],
      if (updates.containsKey('ratePerTon') || updates.containsKey('rate_per_ton'))
        'rate_per_ton': updates['ratePerTon'] ?? updates['rate_per_ton'],
      if (updates.containsKey('advanceRequired') ||
          updates.containsKey('advance_required'))
        'advance_required':
            updates['advanceRequired'] ?? updates['advance_required'],
      if (updates.containsKey('advancePercent') || updates.containsKey('advance_percent'))
        'advance_percent': updates['advancePercent'] ?? updates['advance_percent'],
      if (updates.containsKey('paymentTerms') ||
          updates.containsKey('payment_terms'))
        'payment_terms': updates['paymentTerms'] ?? updates['payment_terms'],
      if (updates.containsKey('loadingDate') ||
          updates.containsKey('loading_date'))
        'loading_date': loadingDateRaw is DateTime
            ? loadingDateRaw.toIso8601String()
            : loadingDateRaw,
      if (updates.containsKey('notes')) 'notes': updates['notes'],
      if (updates.containsKey('contactPreferencesCall') ||
          updates.containsKey('contact_preferences_call'))
        'contact_preferences_call': updates['contactPreferencesCall'] ??
            updates['contact_preferences_call'],
      if (updates.containsKey('contactPreferencesChat') ||
          updates.containsKey('contact_preferences_chat'))
        'contact_preferences_chat': updates['contactPreferencesChat'] ??
            updates['contact_preferences_chat'],
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

        return await query.order('created_at', ascending: false).range(from, to)
            as List;
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
      final Map<String, dynamic>? data =
          await _client.from('loads').select().eq('id', id).maybeSingle();

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
      final data = await _client
          .from('truck_types')
          .select('name')
          .eq('is_active', true)
          .order('name') as List;

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
          .eq('is_active', true)
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
