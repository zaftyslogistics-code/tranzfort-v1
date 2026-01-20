import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/truck.dart';
import '../../domain/repositories/fleet_repository.dart';
import '../../data/datasources/fleet_datasource.dart';
import '../../data/datasources/supabase_fleet_datasource.dart';
import '../../data/repositories/fleet_repository_impl.dart';

// Data Source
final fleetDataSourceProvider = Provider<FleetDataSource>((ref) {
  return SupabaseFleetDataSource(Supabase.instance.client);
});

// Repository
final fleetRepositoryProvider = Provider<FleetRepository>((ref) {
  final dataSource = ref.watch(fleetDataSourceProvider);
  return FleetRepositoryImpl(dataSource);
});

// State
class FleetState {
  final List<Truck> trucks;
  final bool isLoading;
  final String? error;

  FleetState({
    this.trucks = const [],
    this.isLoading = false,
    this.error,
  });

  FleetState copyWith({
    List<Truck>? trucks,
    bool? isLoading,
    String? error,
  }) {
    return FleetState(
      trucks: trucks ?? this.trucks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier
class FleetNotifier extends StateNotifier<FleetState> {
  final FleetRepository _repository;

  FleetNotifier(this._repository) : super(FleetState());

  Future<void> fetchTrucks() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.getTrucks();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (trucks) => state = state.copyWith(isLoading: false, trucks: trucks),
    );
  }

  Future<bool> addTruck(Map<String, dynamic> truckData, {XFile? rcDocument, XFile? insuranceDocument}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.addTruck(truckData, rcDocument: rcDocument, insuranceDocument: insuranceDocument);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (truck) {
        state = state.copyWith(
          isLoading: false,
          trucks: [truck, ...state.trucks],
        );
        return true;
      },
    );
  }

  Future<bool> updateTruck(String id, Map<String, dynamic> updates, {XFile? rcDocument, XFile? insuranceDocument}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.updateTruck(id, updates, rcDocument: rcDocument, insuranceDocument: insuranceDocument);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (updatedTruck) {
        final updatedList = state.trucks.map((t) => t.id == id ? updatedTruck : t).toList();
        state = state.copyWith(isLoading: false, trucks: updatedList);
        return true;
      },
    );
  }

  Future<bool> deleteTruck(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.deleteTruck(id);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        final updatedList = state.trucks.where((t) => t.id != id).toList();
        state = state.copyWith(isLoading: false, trucks: updatedList);
        return true;
      },
    );
  }
}

// Provider
final fleetNotifierProvider = StateNotifierProvider<FleetNotifier, FleetState>((ref) {
  final repository = ref.watch(fleetRepositoryProvider);
  return FleetNotifier(repository);
});
