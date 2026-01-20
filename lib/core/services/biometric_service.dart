import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

class BiometricService {
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _userIdKey = 'biometric_user_id';
  static const String _pinKey = 'biometric_pin';

  final LocalAuthentication _localAuth = LocalAuthentication();
  final SharedPreferences _prefs;

  BiometricService(this._prefs);

  Future<bool> get isBiometricAvailable async {
    try {
      final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final canAuthenticate = await _localAuth.isDeviceSupported();
      return canAuthenticateWithBiometrics && canAuthenticate;
    } catch (e) {
      Logger.error('Error checking biometric availability', error: e);
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      Logger.error('Error getting available biometrics', error: e);
      return [];
    }
  }

  Future<bool> authenticate(String reason) async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return authenticated;
    } catch (e) {
      Logger.error('Biometric authentication error', error: e);
      return false;
    }
  }

  Future<void> enableBiometric(String userId) async {
    await _prefs.setBool(_biometricEnabledKey, true);
    await _prefs.setString(_userIdKey, userId);
  }

  Future<void> disableBiometric() async {
    await _prefs.setBool(_biometricEnabledKey, false);
    await _prefs.remove(_userIdKey);
  }

  bool get isBiometricEnabled => _prefs.getBool(_biometricEnabledKey) ?? false;

  String? get biometricUserId => _prefs.getString(_userIdKey);

  Future<void> setPin(String pin) async {
    await _prefs.setString(_pinKey, pin);
  }

  Future<bool> authenticateWithPin(String enteredPin) async {
    final storedPin = _prefs.getString(_pinKey);
    return storedPin == enteredPin;
  }

  bool get hasPin => _prefs.getString(_pinKey) != null;

  Future<bool> authenticateWithFallback() async {
    // Try biometric first
    if (isBiometricEnabled && await isBiometricAvailable) {
      final biometricSuccess = await authenticate('Authenticate to access your account');
      if (biometricSuccess) return true;
    }

    // Fallback to PIN if available
    if (hasPin) {
      // This would need UI integration to prompt for PIN
      // For now, return false - UI will handle PIN prompt
      return false; // Indicate PIN fallback needed
    }

    return false;
  }

  Future<bool> authenticateUser(String userId) async {
    if (!isBiometricEnabled || biometricUserId != userId) {
      return false;
    }

    return await authenticate('Authenticate to access your account');
  }
}
