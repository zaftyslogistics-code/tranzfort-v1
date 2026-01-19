import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../../../../core/utils/logger.dart';
import '../models/user_model.dart';
import '../models/admin_model.dart';

abstract class AuthDataSource {
  Future<void> sendOtp(String mobileNumber, String countryCode);
  Future<UserModel> verifyOtp(String mobileNumber, String otp);
  Future<UserModel?> getCurrentUser();
  Future<void> signOut();
  Future<UserModel> updateProfile(String userId, Map<String, dynamic> updates);
  Future<AdminModel?> getAdminProfile(String userId);
}

class MockAuthDataSource implements AuthDataSource {
  final SharedPreferences prefs;
  final Uuid uuid = const Uuid();

  MockAuthDataSource(this.prefs);

  @override
  Future<void> sendOtp(String mobileNumber, String countryCode) async {
    Logger.info('📱 MOCK: Sending OTP to $countryCode$mobileNumber');
    Logger.info('🔐 MOCK: OTP Code is: 123456 (accept any 6-digit code)');
    
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<UserModel> verifyOtp(String mobileNumber, String otp) async {
    Logger.info('✅ MOCK: Verifying OTP $otp for $mobileNumber');
    
    if (otp.length != 6) {
      throw Exception('Invalid OTP length');
    }

    await Future.delayed(const Duration(seconds: 1));

    final existingUserJson = prefs.getString('user_$mobileNumber');
    
    if (existingUserJson != null) {
      final user = UserModel.fromJson(jsonDecode(existingUserJson));
      final updatedUser = user.copyWith(lastLoginAt: DateTime.now());
      await _saveUser(updatedUser);
      await prefs.setString('current_user_id', updatedUser.id);
      Logger.info('👤 MOCK: Existing user logged in: ${updatedUser.id}');
      return updatedUser;
    } else {
      final newUser = UserModel(
        id: uuid.v4(),
        mobileNumber: mobileNumber,
        countryCode: '+91',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _saveUser(newUser);
      await prefs.setString('current_user_id', newUser.id);
      Logger.info('🆕 MOCK: New user created: ${newUser.id}');
      return newUser;
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final userId = prefs.getString('current_user_id');
    if (userId == null) {
      Logger.info('❌ MOCK: No current user');
      return null;
    }

    final allKeys = prefs.getKeys();
    for (final key in allKeys) {
      if (key.startsWith('user_')) {
        final userJson = prefs.getString(key);
        if (userJson != null) {
          final user = UserModel.fromJson(jsonDecode(userJson));
          if (user.id == userId) {
            Logger.info('👤 MOCK: Current user found: ${user.id}');
            return user;
          }
        }
      }
    }

    Logger.info('❌ MOCK: User not found for ID: $userId');
    return null;
  }

  @override
  Future<void> signOut() async {
    await prefs.remove('current_user_id');
    Logger.info('👋 MOCK: User signed out');
  }

  @override
  Future<UserModel> updateProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    Logger.info('📝 MOCK: Updating profile for $userId: $updates');
    
    final currentUser = await getCurrentUser();
    if (currentUser == null || currentUser.id != userId) {
      throw Exception('User not found');
    }

    final updatedUserJson = {
      ...currentUser.toJson(),
      ...updates,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final updatedUser = UserModel.fromJson(updatedUserJson);
    await _saveUser(updatedUser);
    
    Logger.info('✅ MOCK: Profile updated successfully');
    return updatedUser;
  }

  @override
  Future<AdminModel?> getAdminProfile(String userId) async {
    // For mock purposes, if user exists, they are a super_admin
    final user = await getCurrentUser();
    if (user != null && user.id == userId) {
      return AdminModel(
        id: userId,
        role: 'super_admin',
        fullName: 'Mock Admin',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
    return null;
  }

  Future<void> _saveUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await prefs.setString('user_${user.mobileNumber}', userJson);
  }
}
