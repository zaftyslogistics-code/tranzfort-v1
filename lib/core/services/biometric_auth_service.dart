import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

/// Biometric authentication service
/// Provides fingerprint and face recognition authentication
class BiometricAuthService {
  static final BiometricAuthService _instance =
      BiometricAuthService._internal();
  factory BiometricAuthService() => _instance;
  BiometricAuthService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  static const String _biometricEnabledKey = 'biometric_enabled';

  /// Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      Logger.error('Error checking biometric availability', error: e);
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      Logger.error('Error getting available biometrics', error: e);
      return [];
    }
  }

  /// Authenticate with biometrics
  Future<bool> authenticate({
    String reason = 'Please authenticate to continue',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      // Check if biometric is available
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        Logger.warning('Biometric authentication not available');
        return false;
      }

      // Check if biometric is enabled by user
      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) {
        Logger.info('Biometric authentication not enabled by user');
        return false;
      }

      // Authenticate
      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        Logger.info('✅ Biometric authentication successful');
      } else {
        Logger.warning('❌ Biometric authentication failed');
      }

      return authenticated;
    } on PlatformException catch (e) {
      Logger.error('Biometric authentication error', error: e);
      return false;
    } catch (e) {
      Logger.error('Unexpected biometric error', error: e);
      return false;
    }
  }

  /// Enable biometric authentication
  Future<void> enableBiometric() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricEnabledKey, true);
      Logger.info('Biometric authentication enabled');
    } catch (e) {
      Logger.error('Failed to enable biometric', error: e);
    }
  }

  /// Disable biometric authentication
  Future<void> disableBiometric() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricEnabledKey, false);
      Logger.info('Biometric authentication disabled');
    } catch (e) {
      Logger.error('Failed to disable biometric', error: e);
    }
  }

  /// Check if biometric is enabled by user
  Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_biometricEnabledKey) ?? false;
    } catch (e) {
      Logger.error('Failed to check biometric status', error: e);
      return false;
    }
  }

  /// Get biometric type name
  String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face Recognition';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris Scan';
      case BiometricType.strong:
        return 'Strong Biometric';
      case BiometricType.weak:
        return 'Weak Biometric';
    }
  }

  /// Stop authentication (cancel)
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
      Logger.info('Biometric authentication stopped');
    } catch (e) {
      Logger.error('Failed to stop authentication', error: e);
    }
  }

  /// Check if device supports biometric
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      Logger.error('Error checking device support', error: e);
      return false;
    }
  }
}
