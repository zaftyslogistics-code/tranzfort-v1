import '../models/load_model.dart';
import '../models/truck_type_model.dart';
import '../models/material_type_model.dart';

abstract class LoadsDataSource {
  Future<LoadModel> createLoad(Map<String, dynamic> loadData);

  Future<List<LoadModel>> getLoads({
    String? status,
    String? supplierId,
    String? searchQuery,
    int page = 0,
    int pageSize = 20,
  });

  Future<LoadModel?> getLoadById(String id);

  Future<LoadModel> updateLoad(String id, Map<String, dynamic> updates);

  Future<void> deleteLoad(String id);

  Future<void> incrementViewCount(String id);

  Future<List<TruckTypeModel>> getTruckTypes();

  Future<List<MaterialTypeModel>> getMaterialTypes();
}
