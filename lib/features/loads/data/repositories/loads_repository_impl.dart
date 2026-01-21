import 'package:dartz/dartz.dart';
import '../../domain/entities/load.dart';
import '../../domain/entities/truck_type.dart';
import '../../domain/entities/material_type.dart';
import '../../domain/repositories/loads_repository.dart';
import '../datasources/loads_datasource.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';

class LoadsRepositoryImpl implements LoadsRepository {
  final LoadsDataSource _primary;
  final LoadsDataSource? _fallback;

  LoadsRepositoryImpl(
    this._primary, {
    LoadsDataSource? fallback,
  }) : _fallback = fallback;

  Future<T> _withFallback<T>(Future<T> Function(LoadsDataSource ds) fn) async {
    try {
      return await fn(_primary);
    } catch (e) {
      if (_fallback == null) rethrow;
      return await fn(_fallback);
    }
  }

  @override
  Future<Either<Failure, Load>> createLoad(Map<String, dynamic> loadData) async {
    try {
      final loadModel = await _withFallback((ds) => ds.createLoad(loadData));
      return Right(_modelToEntity(loadModel));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Load>>> getLoads({
    String? status,
    String? supplierId,
    String? searchQuery,
  }) async {
    try {
      final loadModels = await _withFallback(
        (ds) => ds.getLoads(
          status: status,
          supplierId: supplierId,
          searchQuery: searchQuery,
        ),
      );
      return Right(loadModels.map(_modelToEntity).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Load?>> getLoadById(String id) async {
    try {
      final loadModel = await _withFallback((ds) => ds.getLoadById(id));
      if (loadModel == null) return const Right(null);
      return Right(_modelToEntity(loadModel));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Load>> updateLoad(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final loadModel = await _withFallback((ds) => ds.updateLoad(id, updates));
      return Right(_modelToEntity(loadModel));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLoad(String id) async {
    try {
      await _withFallback((ds) => ds.deleteLoad(id));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> incrementViewCount(String id) async {
    try {
      await _withFallback((ds) => ds.incrementViewCount(id));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TruckType>>> getTruckTypes() async {
    try {
      final models = await _withFallback((ds) => ds.getTruckTypes());
      return Right(models.map((m) => TruckType(
        id: m.id,
        name: m.name,
        category: m.category,
        displayOrder: m.displayOrder,
      )).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MaterialType>>> getMaterialTypes() async {
    try {
      final models = await _withFallback((ds) => ds.getMaterialTypes());
      return Right(models.map((m) => MaterialType(
        id: m.id,
        name: m.name,
        category: m.category,
        displayOrder: m.displayOrder,
      )).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Load _modelToEntity(loadModel) {
    return Load(
      id: loadModel.id,
      supplierId: loadModel.supplierId,
      fromLocation: loadModel.fromLocation,
      fromCity: loadModel.fromCity,
      fromState: loadModel.fromState,
      toLocation: loadModel.toLocation,
      toCity: loadModel.toCity,
      toState: loadModel.toState,
      loadType: loadModel.loadType,
      truckTypeRequired: loadModel.truckTypeRequired,
      weight: loadModel.weight,
      price: loadModel.price,
      priceType: loadModel.priceType,
      paymentTerms: loadModel.paymentTerms,
      loadingDate: loadModel.loadingDate,
      notes: loadModel.notes,
      contactPreferencesCall: loadModel.contactPreferencesCall,
      contactPreferencesChat: loadModel.contactPreferencesChat,
      status: loadModel.status,
      expiresAt: loadModel.expiresAt,
      viewCount: loadModel.viewCount,
      createdAt: loadModel.createdAt,
      updatedAt: loadModel.updatedAt,
    );
  }
}
