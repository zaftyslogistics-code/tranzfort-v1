import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/remote_config_service.dart';

// Provider for RemoteConfigService instance
final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService();
});

// Provider for remote configuration
final remoteConfigProvider = FutureProvider<RemoteConfig>((ref) async {
  final service = ref.watch(remoteConfigServiceProvider);
  return service.getConfig();
});

// Specific feature flag providers for easy access
final adsEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(remoteConfigServiceProvider);
  return service.areAdsEnabled();
});

final maintenanceModeProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(remoteConfigServiceProvider);
  return service.isMaintenanceMode();
});

final loadExpiryDaysProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(remoteConfigServiceProvider);
  return service.getLoadExpiryDays();
});

final maxLoadsPerUserProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(remoteConfigServiceProvider);
  return service.getMaxLoadsPerUser();
});

// Provider to check if current app version is supported
final appVersionSupportedProvider = FutureProvider.family<bool, String>((ref, currentVersion) async {
  final service = ref.watch(remoteConfigServiceProvider);
  return service.isVersionSupported(currentVersion);
});
