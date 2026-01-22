import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/config/env_config.dart';

class SystemConfig {
  final bool enableAds;
  final int verificationFeeTrucker;
  final int verificationFeeSupplier;
  final int loadExpiryDays;

  SystemConfig({
    required this.enableAds,
    required this.verificationFeeTrucker,
    required this.verificationFeeSupplier,
    required this.loadExpiryDays,
  });

  SystemConfig copyWith({
    bool? enableAds,
    int? verificationFeeTrucker,
    int? verificationFeeSupplier,
    int? loadExpiryDays,
  }) {
    return SystemConfig(
      enableAds: enableAds ?? this.enableAds,
      verificationFeeTrucker:
          verificationFeeTrucker ?? this.verificationFeeTrucker,
      verificationFeeSupplier:
          verificationFeeSupplier ?? this.verificationFeeSupplier,
      loadExpiryDays: loadExpiryDays ?? this.loadExpiryDays,
    );
  }
}

class AdminConfigState {
  final SystemConfig config;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  AdminConfigState({
    required this.config,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  AdminConfigState copyWith({
    SystemConfig? config,
    bool? isLoading,
    bool? isSaving,
    String? error,
  }) {
    return AdminConfigState(
      config: config ?? this.config,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }
}

class AdminConfigNotifier extends StateNotifier<AdminConfigState> {
  final SupabaseClient _client;

  AdminConfigNotifier(this._client)
      : super(
          AdminConfigState(
            config: SystemConfig(
              enableAds: EnvConfig.enableAds,
              verificationFeeTrucker: 0,
              verificationFeeSupplier: 0,
              loadExpiryDays: AppConfig.loadExpiryDays,
            ),
          ),
        );

  Future<void> fetchConfig() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final row = await _client
          .from('system_config')
          .select('*')
          .eq('id', 1)
          .maybeSingle();

      if (row == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final config = SystemConfig(
        enableAds: (row['enable_ads'] as bool?) ?? state.config.enableAds,
        verificationFeeTrucker: 0,
        verificationFeeSupplier: 0,
        loadExpiryDays:
            (row['load_expiry_days'] as int?) ?? state.config.loadExpiryDays,
      );

      state = state.copyWith(isLoading: false, config: config);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateEnableAds(bool value) {
    state = state.copyWith(config: state.config.copyWith(enableAds: value));
  }

  void updateLoadExpiryDays(int value) {
    state = state.copyWith(
      config: state.config.copyWith(loadExpiryDays: value),
    );
  }

  Future<bool> saveConfig() async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      await _client.from('system_config').update({
        'enable_ads': state.config.enableAds,
        'load_expiry_days': state.config.loadExpiryDays,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', 1);

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }
}

final adminConfigNotifierProvider =
    StateNotifierProvider<AdminConfigNotifier, AdminConfigState>((ref) {
  final client = Supabase.instance.client;
  return AdminConfigNotifier(client);
});
