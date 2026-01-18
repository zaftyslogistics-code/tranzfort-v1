import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/offline_cache_service.dart';
import '../../../../core/utils/retry.dart';
import '../models/load_model.dart';
import '../models/material_type_model.dart';
import '../models/truck_type_model.dart';
import 'mock_loads_datasource.dart';

class SupabaseLoadsDataSource implements LoadsDataSource {
  final SupabaseClient _client;

  SupabaseLoadsDataSource(this._client);

  String _composeLocation({required String city, String? state}) {
    if (state == null || state.isEmpty) return city;
    return '$city, $state';
  }

  LoadModel _toLoadModel(Map<String, dynamic> row) {
    final supplierId = row['supplier_id'] as String;

    final fromCity = (row['from_city'] ?? row['fromCity']) as String?;
    final fromState = (row['from_state'] ?? row['fromState']) as String?;

    final toCity = (row['to_city'] ?? row['toCity']) as String?;
    final toState = (row['to_state'] ?? row['toState']) as String?;

    final fromLocation = (row['from_location'] ?? row['fromLocation']) as String?;
    final toLocation = (row['to_location'] ?? row['toLocation']) as String?;

    final loadType = (row['load_type'] ?? row['loadType'] ?? row['material_type']) as String?;

    final truckTypeRequired =
        (row['truck_type_required'] ?? row['truckTypeRequired'] ?? row['truck_type']) as String?;

    final weight = (row['weight'] ?? row['weight_in_tons']) as num?;
    final price = row['price'] as num?;

    final priceType = (row['price_type'] ?? row['priceType'] ?? 'negotiable') as String;

    final paymentTerms = (row['payment_terms'] ?? row['paymentTerms']) as String?;

    final loadingDateRaw = row['loading_date'] ?? row['loadingDate'];
    DateTime? loadingDate;
    if (loadingDateRaw is String) {
      loadingDate = DateTime.tryParse(loadingDateRaw);
    }

    final notes = row['notes'] as String?;

    final contactCall =
        (row['contact_preferences_call'] ?? row['contactPreferencesCall']) as bool?;
    final contactChat =
        (row['contact_preferences_chat'] ?? row['contactPreferencesChat']) as bool?;

    final status = (row['status'] as String?) ?? 'active';
    final viewCount = (row['view_count'] as int?) ?? 0;

    final createdAt = DateTime.parse(row['created_at'] as String);
    final updatedAt = DateTime.parse(row['updated_at'] as String);
    final expiresAt = DateTime.parse(row['expires_at'] as String);

    final resolvedFromCity = fromCity ?? '';
    final resolvedToCity = toCity ?? '';

    return LoadModel(
      id: row['id'] as String,
      supplierId: supplierId,
      fromLocation: fromLocation ??
          _composeLocation(city: resolvedFromCity, state: fromState),
      fromCity: resolvedFromCity,
      fromState: fromState,
      toLocation: toLocation ?? _composeLocation(city: resolvedToCity, state: toState),
      toCity: resolvedToCity,
      toState: toState,
      loadType: loadType ?? '',
      truckTypeRequired: truckTypeRequired ?? '',
      weight: weight?.toDouble(),
      price: price?.toDouble(),
      priceType: priceType,
      paymentTerms: paymentTerms,
      loadingDate: loadingDate,
      notes: notes,
      contactPreferencesCall: contactCall ?? true,
      contactPreferencesChat: contactChat ?? true,
      status: status,
      expiresAt: expiresAt,
      viewCount: viewCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> _toInsertPayload(Map<String, dynamic> loadData) {
    return {
      'supplier_id': loadData['supplierId'],
      'from_location': loadData['fromLocation'],
      'from_city': loadData['fromCity'],
      'from_state': loadData['fromState'],
      'to_location': loadData['toLocation'],
      'to_city': loadData['toCity'],
      'to_state': loadData['toState'],
      'load_type': loadData['loadType'],
      'truck_type_required': loadData['truckTypeRequired'],
      'weight': loadData['weight'],
      'price': loadData['price'],
      'price_type': loadData['priceType'] ?? 'negotiable',
      'payment_terms': loadData['paymentTerms'],
      'loading_date': loadData['loadingDate'],
      'notes': loadData['notes'],
      'contact_preferences_call': loadData['contactPreferencesCall'] ?? true,
      'contact_preferences_chat': loadData['contactPreferencesChat'] ?? true,
      'status': loadData['status'] ?? 'active',
      'expires_at': loadData['expiresAt'],
    };
  }

  Map<String, dynamic> _toUpdatePayload(Map<String, dynamic> updates) {
    final payload = <String, dynamic>{};

    void setIfPresent(String key, String column) {
      if (updates.containsKey(key)) {
        payload[column] = updates[key];
      }
    }

    setIfPresent('fromLocation', 'from_location');
    setIfPresent('fromCity', 'from_city');
    setIfPresent('fromState', 'from_state');

    setIfPresent('toLocation', 'to_location');
    setIfPresent('toCity', 'to_city');
    setIfPresent('toState', 'to_state');

    setIfPresent('loadType', 'load_type');
    setIfPresent('truckTypeRequired', 'truck_type_required');

    setIfPresent('weight', 'weight');
    setIfPresent('price', 'price');
    setIfPresent('priceType', 'price_type');

    setIfPresent('paymentTerms', 'payment_terms');
    setIfPresent('loadingDate', 'loading_date');
    setIfPresent('notes', 'notes');

    setIfPresent('contactPreferencesCall', 'contact_preferences_call');
    setIfPresent('contactPreferencesChat', 'contact_preferences_chat');

    setIfPresent('status', 'status');
    setIfPresent('expiresAt', 'expires_at');
    setIfPresent('viewCount', 'view_count');

    return payload;
  }

  @override
  Future<LoadModel> createLoad(Map<String, dynamic> loadData) async {
    try {
      final payload = _toInsertPayload(loadData);
      final Map<String, dynamic> data =
          await _client.from('loads').insert(payload).select().single();
      return _toLoadModel(data);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<LoadModel>> getLoads({String? status, String? supplierId}) async {
    try {
      final data = await retry(() async {
        var query = _client.from('loads').select();

        if (status != null) {
          query = query.eq('status', status);
        }

        if (supplierId != null) {
          query = query.eq('supplier_id', supplierId);
        }

        return await query.order('created_at', ascending: false) as List;
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

      return _toLoadModel(data);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteLoad(String id) async {
    try {
      await _client.from('loads').update({'status': 'deleted'}).eq('id', id);
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
