import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../../../../core/utils/logger.dart';
import '../models/load_model.dart';
import '../models/truck_type_model.dart';
import '../models/material_type_model.dart';

abstract class LoadsDataSource {
  Future<LoadModel> createLoad(Map<String, dynamic> loadData);
  Future<List<LoadModel>> getLoads({String? status, String? supplierId});
  Future<LoadModel?> getLoadById(String id);
  Future<LoadModel> updateLoad(String id, Map<String, dynamic> updates);
  Future<void> deleteLoad(String id);
  Future<void> incrementViewCount(String id);
  Future<List<TruckTypeModel>> getTruckTypes();
  Future<List<MaterialTypeModel>> getMaterialTypes();
}

class MockLoadsDataSource implements LoadsDataSource {
  final SharedPreferences prefs;
  final Uuid uuid = const Uuid();

  MockLoadsDataSource(this.prefs);

  @override
  Future<LoadModel> createLoad(Map<String, dynamic> loadData) async {
    Logger.info('📦 MOCK: Creating load');

    final now = DateTime.now();
    final newLoad = LoadModel(
      id: uuid.v4(),
      supplierId: loadData['supplierId'],
      fromLocation: loadData['fromLocation'],
      fromCity: loadData['fromCity'],
      fromState: loadData['fromState'],
      toLocation: loadData['toLocation'],
      toCity: loadData['toCity'],
      toState: loadData['toState'],
      loadType: loadData['loadType'],
      truckTypeRequired: loadData['truckTypeRequired'],
      weight: loadData['weight'],
      price: loadData['price'],
      priceType: loadData['priceType'] ?? 'negotiable',
      paymentTerms: loadData['paymentTerms'],
      loadingDate: loadData['loadingDate'] is DateTime
          ? loadData['loadingDate']
          : (loadData['loadingDate'] != null
              ? DateTime.parse(loadData['loadingDate'])
              : null),
      notes: loadData['notes'],
      contactPreferencesCall: loadData['contactPreferencesCall'] ?? true,
      contactPreferencesChat: loadData['contactPreferencesChat'] ?? true,
      status: 'active',
      expiresAt: now.add(const Duration(days: 90)),
      viewCount: 0,
      createdAt: now,
      updatedAt: now,
    );

    await _saveLoad(newLoad);
    Logger.info('✅ MOCK: Load created: ${newLoad.id}');
    return newLoad;
  }

  @override
  Future<List<LoadModel>> getLoads({String? status, String? supplierId}) async {
    Logger.info('📋 MOCK: Getting loads (status: $status, supplierId: $supplierId)');

    var allLoads = await _getAllLoads();
    if (allLoads.isEmpty) {
      await _seedSampleLoads();
      allLoads = await _getAllLoads();
    }
    
    var filteredLoads = allLoads;

    if (status != null) {
      filteredLoads = filteredLoads.where((load) => load.status == status).toList();
    }

    if (supplierId != null) {
      filteredLoads = filteredLoads.where((load) => load.supplierId == supplierId).toList();
    }

    // Sort by created date (newest first)
    filteredLoads.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    Logger.info('✅ MOCK: Found ${filteredLoads.length} loads');
    return filteredLoads;
  }

  @override
  Future<LoadModel?> getLoadById(String id) async {
    Logger.info('🔍 MOCK: Getting load by ID: $id');

    final allLoads = await _getAllLoads();
    try {
      final load = allLoads.firstWhere((load) => load.id == id);
      Logger.info('✅ MOCK: Load found');
      return load;
    } catch (e) {
      Logger.info('❌ MOCK: Load not found');
      return null;
    }
  }

  @override
  Future<LoadModel> updateLoad(String id, Map<String, dynamic> updates) async {
    Logger.info('📝 MOCK: Updating load: $id');

    final load = await getLoadById(id);
    if (load == null) {
      throw Exception('Load not found');
    }

    final updatedLoadJson = {
      ...load.toJson(),
      ...updates,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    final updatedLoad = LoadModel.fromJson(updatedLoadJson);
    await _saveLoad(updatedLoad);

    Logger.info('✅ MOCK: Load updated');
    return updatedLoad;
  }

  @override
  Future<void> deleteLoad(String id) async {
    Logger.info('🗑️ MOCK: Deleting load: $id');

    final allLoads = await _getAllLoads();
    final updatedLoads = allLoads.where((load) => load.id != id).toList();
    await _saveAllLoads(updatedLoads);

    Logger.info('✅ MOCK: Load deleted');
  }

  @override
  Future<void> incrementViewCount(String id) async {
    final load = await getLoadById(id);
    if (load != null) {
      await updateLoad(id, {'view_count': load.viewCount + 1});
    }
  }

  @override
  Future<List<TruckTypeModel>> getTruckTypes() async {
    return [
      const TruckTypeModel(id: 1, name: 'Open Body 7ft', category: 'Open Body', displayOrder: 1),
      const TruckTypeModel(id: 2, name: 'Open Body 9ft', category: 'Open Body', displayOrder: 2),
      const TruckTypeModel(id: 3, name: 'Open Body 14ft', category: 'Open Body', displayOrder: 3),
      const TruckTypeModel(id: 4, name: 'Open Body 17ft', category: 'Open Body', displayOrder: 4),
      const TruckTypeModel(id: 5, name: 'Open Body 19ft', category: 'Open Body', displayOrder: 5),
      const TruckTypeModel(id: 6, name: 'Open Body 20ft', category: 'Open Body', displayOrder: 6),
      const TruckTypeModel(id: 7, name: 'Open Body 22ft', category: 'Open Body', displayOrder: 7),
      const TruckTypeModel(id: 8, name: 'Container 20ft', category: 'Container', displayOrder: 8),
      const TruckTypeModel(id: 9, name: 'Container 32ft', category: 'Container', displayOrder: 9),
      const TruckTypeModel(id: 10, name: 'Container 40ft', category: 'Container', displayOrder: 10),
      const TruckTypeModel(id: 11, name: 'Trailer 40ft', category: 'Trailer', displayOrder: 11),
      const TruckTypeModel(id: 12, name: 'Trailer 48ft', category: 'Trailer', displayOrder: 12),
      const TruckTypeModel(id: 13, name: 'Tanker', category: 'Specialized', displayOrder: 13),
      const TruckTypeModel(id: 14, name: 'Tipper', category: 'Specialized', displayOrder: 14),
      const TruckTypeModel(id: 15, name: 'LCV', category: 'Light', displayOrder: 15),
      const TruckTypeModel(id: 16, name: 'Refrigerated', category: 'Specialized', displayOrder: 16),
      const TruckTypeModel(id: 17, name: 'Flatbed', category: 'Specialized', displayOrder: 17),
      const TruckTypeModel(id: 18, name: 'Other', category: 'Other', displayOrder: 18),
    ];
  }

  @override
  Future<List<MaterialTypeModel>> getMaterialTypes() async {
    return [
      const MaterialTypeModel(id: 1, name: 'Agriculture - Grains', category: 'Agriculture', displayOrder: 1),
      const MaterialTypeModel(id: 2, name: 'Agriculture - Vegetables', category: 'Agriculture', displayOrder: 2),
      const MaterialTypeModel(id: 3, name: 'Agriculture - Fruits', category: 'Agriculture', displayOrder: 3),
      const MaterialTypeModel(id: 4, name: 'FMCG', category: 'FMCG', displayOrder: 4),
      const MaterialTypeModel(id: 5, name: 'Building Materials - Cement', category: 'Building Materials', displayOrder: 5),
      const MaterialTypeModel(id: 6, name: 'Building Materials - Steel', category: 'Building Materials', displayOrder: 6),
      const MaterialTypeModel(id: 7, name: 'Building Materials - Bricks', category: 'Building Materials', displayOrder: 7),
      const MaterialTypeModel(id: 8, name: 'Chemicals', category: 'Chemicals', displayOrder: 8),
      const MaterialTypeModel(id: 9, name: 'Electronics', category: 'Electronics', displayOrder: 9),
      const MaterialTypeModel(id: 10, name: 'Textiles', category: 'Textiles', displayOrder: 10),
      const MaterialTypeModel(id: 11, name: 'Furniture', category: 'Furniture', displayOrder: 11),
      const MaterialTypeModel(id: 12, name: 'Machinery', category: 'Machinery', displayOrder: 12),
      const MaterialTypeModel(id: 13, name: 'Petroleum Products', category: 'Petroleum', displayOrder: 13),
      const MaterialTypeModel(id: 14, name: 'Pharmaceuticals', category: 'Pharmaceuticals', displayOrder: 14),
      const MaterialTypeModel(id: 15, name: 'Raw Materials', category: 'Raw Materials', displayOrder: 15),
      const MaterialTypeModel(id: 16, name: 'Scrap/Waste', category: 'Scrap', displayOrder: 16),
      const MaterialTypeModel(id: 17, name: 'Other', category: 'Other', displayOrder: 17),
    ];
  }

  Future<void> _saveLoad(LoadModel load) async {
    final allLoads = await _getAllLoads();
    final index = allLoads.indexWhere((l) => l.id == load.id);
    
    if (index >= 0) {
      allLoads[index] = load;
    } else {
      allLoads.add(load);
    }

    await _saveAllLoads(allLoads);
  }

  Future<List<LoadModel>> _getAllLoads() async {
    final loadsJson = prefs.getString('all_loads');
    if (loadsJson == null) return [];

    final List<dynamic> loadsList = jsonDecode(loadsJson);
    return loadsList.map((json) => LoadModel.fromJson(json)).toList();
  }

  Future<void> _saveAllLoads(List<LoadModel> loads) async {
    final loadsJson = jsonEncode(loads.map((load) => load.toJson()).toList());
    await prefs.setString('all_loads', loadsJson);
  }

  Future<void> _seedSampleLoads() async {
    Logger.info('🌱 MOCK: Seeding sample loads');
    final now = DateTime.now();

    final samples = [
      LoadModel(
        id: uuid.v4(),
        supplierId: 'sample-supplier',
        fromLocation: 'Bhiwandi Warehouse, Mumbai',
        fromCity: 'Mumbai',
        fromState: 'Maharashtra',
        toLocation: 'Okhla Industrial Area, Delhi',
        toCity: 'Delhi',
        toState: 'Delhi',
        loadType: 'FMCG',
        truckTypeRequired: 'Container 20ft',
        weight: 12.5,
        price: 24000,
        priceType: 'fixed',
        paymentTerms: 'To Pay',
        loadingDate: now.add(const Duration(days: 1)),
        notes: 'Fragile items - handle with care',
        contactPreferencesCall: true,
        contactPreferencesChat: true,
        status: 'active',
        expiresAt: now.add(const Duration(days: 60)),
        viewCount: 4,
        createdAt: now.subtract(const Duration(hours: 6)),
        updatedAt: now.subtract(const Duration(hours: 4)),
      ),
      LoadModel(
        id: uuid.v4(),
        supplierId: 'sample-supplier',
        fromLocation: 'Surat Textile Market',
        fromCity: 'Surat',
        fromState: 'Gujarat',
        toLocation: 'Bangalore Central',
        toCity: 'Bengaluru',
        toState: 'Karnataka',
        loadType: 'Textiles',
        truckTypeRequired: 'Open Body 19ft',
        weight: 9.2,
        price: null,
        priceType: 'negotiable',
        paymentTerms: 'Advance Payment',
        loadingDate: now.add(const Duration(days: 2)),
        notes: 'Covered truck preferred',
        contactPreferencesCall: true,
        contactPreferencesChat: false,
        status: 'active',
        expiresAt: now.add(const Duration(days: 45)),
        viewCount: 2,
        createdAt: now.subtract(const Duration(hours: 12)),
        updatedAt: now.subtract(const Duration(hours: 10)),
      ),
      LoadModel(
        id: uuid.v4(),
        supplierId: 'sample-supplier',
        fromLocation: 'Pune Logistics Park',
        fromCity: 'Pune',
        fromState: 'Maharashtra',
        toLocation: 'Hyderabad Distribution Hub',
        toCity: 'Hyderabad',
        toState: 'Telangana',
        loadType: 'Electronics',
        truckTypeRequired: 'Container 32ft',
        weight: 7.5,
        price: 18000,
        priceType: 'fixed',
        paymentTerms: 'Negotiable',
        loadingDate: now.add(const Duration(days: 3)),
        notes: null,
        contactPreferencesCall: true,
        contactPreferencesChat: true,
        status: 'active',
        expiresAt: now.subtract(const Duration(days: 1)),
        viewCount: 8,
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
    ];

    await _saveAllLoads(samples);
  }
}
