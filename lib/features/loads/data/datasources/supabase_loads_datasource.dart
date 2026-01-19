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

  LoadModel _toLoadModel(Map<String, dynamic> row) {
    return LoadModel.fromJson(row);
  }

  Map<String, dynamic> _toInsertPayload(Map<String, dynamic> loadData) {
    return LoadModel.fromJson(loadData).toJson();
  }

  Map<String, dynamic> _toUpdatePayload(Map<String, dynamic> updates) {
    return updates; // Temporary simplification, should be audited
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
  Future<List<LoadModel>> getLoads({
    String? status,
    String? supplierId,
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
