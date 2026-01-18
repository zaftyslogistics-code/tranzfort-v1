import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/mock_loads_datasource.dart';
import '../../data/datasources/supabase_loads_datasource.dart';
import '../../data/repositories/loads_repository_impl.dart';
import '../../domain/entities/load.dart';
import '../../domain/entities/truck_type.dart';
import '../../domain/entities/material_type.dart';
import '../../domain/usecases/create_load.dart';
import '../../domain/usecases/get_loads.dart';
import '../../domain/usecases/get_load_by_id.dart';
import '../../domain/usecases/update_load.dart';
import '../../domain/usecases/delete_load.dart';
import '../../domain/usecases/get_truck_types.dart';
import '../../domain/usecases/get_material_types.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/config/env_config.dart';

final loadsDataSourceProvider = Provider<LoadsDataSource>((ref) {
  if (EnvConfig.useMockLoads) {
    final prefs = ref.watch(sharedPreferencesProvider);
    return MockLoadsDataSource(prefs);
  }

  final supabase = Supabase.instance.client;
  return SupabaseLoadsDataSource(supabase);
});

final loadsRepositoryProvider = Provider((ref) {
  final primary = ref.watch(loadsDataSourceProvider);

  final prefs = ref.watch(sharedPreferencesProvider);
  final fallback = MockLoadsDataSource(prefs);

  return LoadsRepositoryImpl(
    primary,
    fallback: fallback,
  );
});

final createLoadUseCaseProvider = Provider((ref) {
  final repository = ref.watch(loadsRepositoryProvider);
  return CreateLoad(repository);
});

final getLoadsUseCaseProvider = Provider((ref) {
  final repository = ref.watch(loadsRepositoryProvider);
  return GetLoads(repository);
});

final getLoadByIdUseCaseProvider = Provider((ref) {
  final repository = ref.watch(loadsRepositoryProvider);
  return GetLoadById(repository);
});

final updateLoadUseCaseProvider = Provider((ref) {
  final repository = ref.watch(loadsRepositoryProvider);
  return UpdateLoad(repository);
});

final deleteLoadUseCaseProvider = Provider((ref) {
  final repository = ref.watch(loadsRepositoryProvider);
  return DeleteLoad(repository);
});

final getTruckTypesUseCaseProvider = Provider((ref) {
  final repository = ref.watch(loadsRepositoryProvider);
  return GetTruckTypes(repository);
});

final getMaterialTypesUseCaseProvider = Provider((ref) {
  final repository = ref.watch(loadsRepositoryProvider);
  return GetMaterialTypes(repository);
});

class LoadsState {
  final List<Load> loads;
  final Load? selectedLoad;
  final bool isLoading;
  final String? error;
  final String currentFilter;

  LoadsState({
    this.loads = const [],
    this.selectedLoad,
    this.isLoading = false,
    this.error,
    this.currentFilter = 'active',
  });

  LoadsState copyWith({
    List<Load>? loads,
    Load? selectedLoad,
    bool? isLoading,
    String? error,
    String? currentFilter,
  }) {
    return LoadsState(
      loads: loads ?? this.loads,
      selectedLoad: selectedLoad ?? this.selectedLoad,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

class LoadsNotifier extends StateNotifier<LoadsState> {
  final GetLoads getLoadsUseCase;
  final GetLoadById getLoadByIdUseCase;
  final CreateLoad createLoadUseCase;
  final UpdateLoad updateLoadUseCase;
  final DeleteLoad deleteLoadUseCase;

  LoadsNotifier({
    required this.getLoadsUseCase,
    required this.getLoadByIdUseCase,
    required this.createLoadUseCase,
    required this.updateLoadUseCase,
    required this.deleteLoadUseCase,
  }) : super(LoadsState());

  Future<void> fetchLoads({String? status, String? supplierId}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await getLoadsUseCase(status: status, supplierId: supplierId);
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (loads) {
        state = state.copyWith(
          loads: loads,
          isLoading: false,
          currentFilter: status ?? 'all',
        );
      },
    );
  }

  Future<void> fetchLoadById(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await getLoadByIdUseCase(id);
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (load) {
        state = state.copyWith(selectedLoad: load, isLoading: false);
      },
    );
  }

  Future<bool> createLoad(Map<String, dynamic> loadData) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await createLoadUseCase(loadData);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (load) {
        final updatedLoads = [load, ...state.loads];
        state = state.copyWith(loads: updatedLoads, isLoading: false);
        return true;
      },
    );
  }

  Future<bool> updateLoad(String id, Map<String, dynamic> updates) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await updateLoadUseCase(id, updates);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (updatedLoad) {
        final updatedLoads = state.loads.map((load) {
          return load.id == id ? updatedLoad : load;
        }).toList();
        state = state.copyWith(
          loads: updatedLoads,
          selectedLoad: updatedLoad,
          isLoading: false,
        );
        return true;
      },
    );
  }

  Future<bool> deleteLoad(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await deleteLoadUseCase(id);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        final updatedLoads = state.loads.where((load) => load.id != id).toList();
        state = state.copyWith(loads: updatedLoads, isLoading: false);
        return true;
      },
    );
  }

  void setFilter(String filter) {
    state = state.copyWith(currentFilter: filter);
  }
}

final loadsNotifierProvider =
    StateNotifierProvider<LoadsNotifier, LoadsState>((ref) {
  return LoadsNotifier(
    getLoadsUseCase: ref.watch(getLoadsUseCaseProvider),
    getLoadByIdUseCase: ref.watch(getLoadByIdUseCaseProvider),
    createLoadUseCase: ref.watch(createLoadUseCaseProvider),
    updateLoadUseCase: ref.watch(updateLoadUseCaseProvider),
    deleteLoadUseCase: ref.watch(deleteLoadUseCaseProvider),
  );
});

// Master data providers
final truckTypesProvider = FutureProvider<List<TruckType>>((ref) async {
  final useCase = ref.watch(getTruckTypesUseCaseProvider);
  final result = await useCase();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (truckTypes) => truckTypes,
  );
});

final materialTypesProvider = FutureProvider<List<MaterialType>>((ref) async {
  final useCase = ref.watch(getMaterialTypesUseCaseProvider);
  final result = await useCase();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (materialTypes) => materialTypes,
  );
});
